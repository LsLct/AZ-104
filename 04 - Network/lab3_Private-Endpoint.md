https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-powershell?tabs=dynamic-ip

We'll deploy the following architecture with Powershell:

![schema](.misc/network_lab3.png "schema")  

➡ This lab setup is very similar to the one in [lab1](./lab1_Bastion.md), except that :
- we'll have only one VM in the ***subnet-1***
- and we'll add a private endpoint pointing to the webapp deployed in the [compute_lab1](../03%20-%20Compute/lab1_AppService)  

The goal here is to be able to access an Azure WebApp privately with the help of a private endpoint. So instead of going through the internet to access the WebApp from the VM, the trafic will transit directly through the Azure network backbone with the help of virtual private IP.  
It's as if the WebApp had an network interface / IP address directly connected to our private network.  

So we'll be able to give a private DNS record to this WebApp that will be resolvable only by resources in our virtual network.
  
Cmdlets used in this lab:
- [New-AzPrivateEndpoint](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azprivateendpoint?view=azps-14.5.0)
- [New-AzPrivateLinkServiceConnection](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azprivatelinkserviceconnection?view=azps-14.6.0)
- [New-AzPrivateEndpointIpConfiguration](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azprivateendpointipconfiguration?view=azps-14.6.0)
- [New-AzPrivateDnsZone](https://learn.microsoft.com/en-us/powershell/module/az.privatedns/new-azprivatednszone?view=azps-14.6.0)
- [New-AzPrivateDnsVirtualNetworkLink](https://learn.microsoft.com/en-us/powershell/module/az.privatedns/new-azprivatednsvirtualnetworklink?view=azps-14.6.0)
- [New-AzPrivateDnsZoneGroup](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azprivatednszonegroup?view=azps-14.6.0)
---

### 1/ Initial setup :

Since the architecture is very similar to the one we have in lab 1, let's deploy this quickly in one block :  
```powershell
$rg = "network_lab3"
$location = "francecentral"
$vnet = "vnet-3"

New-AzResourceGroup -Name $rg -Location $location

# Virtual network
$vnet_param = @{
    Name                = $vnet
    ResourceGroupName   = $rg
    Location            = $location
    AddressPrefix       = '192.168.0.0/16'
}
$virtualNetwork = New-AzVirtualNetwork @vnet_param

# VMs subnet
$subnet_param = @{
    Name            = 'subnet-1'
    VirtualNetwork  = $virtualNetwork
    AddressPrefix   = '192.168.40.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet_param
$virtualNetwork | Set-AzVirtualNetwork

# Bastion subnet
$bastion_subnet = @{
    Name            = 'AzureBastionSubnet'
    VirtualNetwork  = $virtualNetwork
    AddressPrefix   = '192.168.1.0/26'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @bastion_subnet
$virtualNetwork | Set-AzVirtualNetwork

# Bastion Public IP
$ip = @{
        ResourceGroupName   = $rg
        Name                = 'public-ip'
        Location            = $location
        AllocationMethod    = 'Static'
        Sku                 = 'Standard'
        Zone                = 1,2,3
}
New-AzPublicIpAddress @ip

# VM
$securePassword = ConvertTo-SecureString -String "P@ssw0rd33!" -AsPlainText -Force
$user = "louis"
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword)
$virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnet

$nic_param = @{
    Name              = 'vm1-nic1'
    ResourceGroupName = $rg
    Location          = $location
    Subnet            = $virtualNetwork.Subnets | ?{$_.Name -eq 'subnet-1'}
}
$nicVM = New-AzNetworkInterface @nic_param

$vmsz = @{
    VMName = 'vm1'
    VMSize = 'Standard_B2als_v2'  
}

$vmos = @{
    ComputerName = 'vm1'
    Credential   = $cred
}

$vmimage = @{
    PublisherName = 'Canonical'
    Offer         = '0001-com-ubuntu-server-jammy'
    Skus          = '22_04-lts-gen2'
    Version       = 'latest'
}

$vmConfig = New-AzVMConfig @vmsz `
    | Set-AzVMOperatingSystem @vmos -Linux `
    | Set-AzVMSourceImage @vmimage `
    | Add-AzVMNetworkInterface -Id $nicVM.Id `
    | Set-AzVMBootDiagnostic -Disable

$vm = @{
    ResourceGroupName = $rg
    Location          = $location
    VM                = $vmConfig
}
New-AzVM @vm

# Bastion host
$bastion = @{
    Name                    = 'bastion'
    ResourceGroupName       = $rg
    PublicIpAddressRgName   = $rg
    PublicIpAddressName     = 'public-ip'
    VirtualNetworkRgName    = $rg
    VirtualNetworkName      = $vnet
    Sku                     = 'Basic'
}
New-AzBastion @bastion
```  

### 2/ Deploying the Web App

We'll deploy the same WebApp as the one deployed in [Lab1_AppService lab](../03%20-%20Compute/lab1_AppService.md). Check the link for more details, here's the short version:  

```powershell
cd ~/Louis/Desktop/webApp/Lab1

$webApp = @{
    Name                = "lolecatnetworklab3"
    Location            = $location
    ResourceGroupName   = $rg
}
New-AzWebApp @webApp

$release = @{
    ArchivePath         = (Get-Item .\bin\Release\net8.0\publish\deploy.zip).FullName # ArchivePath parameter needs the full path of the file, that's why we're referencing to the .FullName property
    Name                = "lolecatnetworklab3"
    ResourceGroupName   = $rg
}
Publish-AzWebApp @release -Force

```

---
### Next steps  

Now, we have a VM in a private network which can be accessed through a Bastion host, and an Azure WebApp accessible via Internet.  
Let's create a private endpoint with its private link to be able to access the WebApp directly through our virtual network.  
Then, a private DNS to get the WebApp's private endpoint IP from its hostname query.

---

### 4/ Private Endpoint creation
  
```powershell
$webapp = Get-AzWebApp -ResourceGroupName $rg -Name "lolecatnetworklab3"

# Create the private endpoint connection
$private_conn = @{
    Name                    = 'webapp-connection'
    PrivateLinkServiceId    = $webapp.ID
    GroupID                 = 'sites'
}
$privateEndpointConnection = New-AzPrivateLinkServiceConnection @private_conn

# Create the private endpoint with its connection
$pe_param = @{
    ResourceGroupName               = $rg
    Name                            = 'private-endpoint'
    Location                        = $location
    Subnet                          = $(Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnet).Subnets[0]
    PrivateLinkServiceConnection    = $privateEndpointConnection
}
New-AzPrivateEndpoint @pe_param
```
---
➡ As soon as a Private Endpoit is created for an Azure WebApp, its Internet access will be blocked. It's the default behavior.  
It's still possible to enable access from all networks afterward, in the **Azure Portal -> WebApp settings -> Networking**.  
From here we can configure the inbound traffic configuration.

---

### 5/ Private DNS Zone creation

[🪢 More infos on private DNS zones for private endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)

```powershell
# Create the private DNS zone
$zone_param = @{
    ResourceGroupName = $rg
    Name = 'privatelink.azurewebsites.net'
}
$zone = New-AzPrivateDnsZone @zone_param

# Create a DNS network link
$link_param = @{
    ResourceGroupName = $rg
    ZoneName = 'privatelink.azurewebsites.net'
    Name = 'dns-link'
    VirtualNetworkId = $(Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnet).Id
}
$link = New-AzPrivateDnsVirtualNetworkLink @link_param

# Configure the DNS zone
$cg = @{
    Name = 'privatelink.azurewebsites.net'
    PrivateDnsZoneId = $zone.ResourceId
}
$config = New-AzPrivateDnsZoneConfig @cg

# Create the DNS zone group
$zg = @{
    ResourceGroupName = $rg
    PrivateEndpointName = 'private-endpoint'
    Name = 'zone-group'
    PrivateDnsZoneConfig = $config
}
New-AzPrivateDnsZoneGroup @zg
```

### Testing

Connect to the VM through the Bastion host, then query the DNS for the WebApp record :

```
louis@vm1:~$ dig lolecatnetworklab3.azurewebsites.net

; <<>> DiG 9.18.39-0ubuntu0.22.04.2-Ubuntu <<>> lolecatnetworklab3.azurewebsites.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60526
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;lolecatnetworklab3.azurewebsites.net. IN A

;; ANSWER SECTION:
lolecatnetworklab3.azurewebsites.net. 60 IN CNAME lolecatnetworklab3.privatelink.azurewebsites.net.
lolecatnetworklab3.privatelink.azurewebsites.net. 10 INA 192.168.40.5

;; Query time: 15 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Fri Nov 14 10:36:45 UTC 2025
;; MSG SIZE  rcvd: 126
```
➡ It returns the private link IP, as well as the correct CNAME.  
Then, we can test if our resource is accessible with a curl :

```
louis@vm1:~$ curl -s https://lolecatnetworklab3.azurewebsites.net

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home page - Lab1</title>
    <link rel="stylesheet" href="/lib/bootstrap/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="/css/site.css?v=pAGv4ietcJNk_EwsQZ5BN9-K4MuNYS2a9wl4Jw-q9D0" />
    <link rel="stylesheet" href="/Lab1.styles.css?v=6bxqfDhaN7ZlFIvbGOmBhvOOfUCIJBZsaDfJrP-OqQE" />
</head>
<body>
    <header b-w63aox5a8i>
        <nav b-w63aox5a8i class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
            <div b-w63aox5a8i class="container">
                <a class="navbar-brand" href="/">Lab1</a>
                <button b-w63aox5a8i class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target=".navbar-collapse" aria-controls="navbarSupportedContent"
                        aria-expanded="false" aria-label="Toggle navigation">
                    <span b-w63aox5a8i class="navbar-toggler-icon"></span>
                </button>
                <div b-w63aox5a8i class="navbar-collapse collapse d-sm-inline-flex justify-content-between">
                    <ul b-w63aox5a8i class="navbar-nav flex-grow-1">
                        <li b-w63aox5a8i class="nav-item">
                            <a class="nav-link text-dark" href="/">Home</a>
                        </li>
                        <li b-w63aox5a8i class="nav-item">
                            <a class="nav-link text-dark" href="/Privacy">Privacy</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>
    <div b-w63aox5a8i class="container">
        <main b-w63aox5a8i role="main" class="pb-3">
            
<div class="text-center">
    <h1 class="display-4">Welcome</h1>
    <p>Learn about <a href="https://learn.microsoft.com/aspnet/core">building Web apps with ASP.NET Core</a>.</p>
</div>

        </main>
    </div>

    <footer b-w63aox5a8i class="border-top footer text-muted">
        <div b-w63aox5a8i class="container">
            &copy; 2025 - Lab1 - <a href="/Privacy">Privacy</a>
        </div>
    </footer>

    <script src="/lib/jquery/dist/jquery.min.js"></script>
    <script src="/lib/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/js/site.js?v=hRQyftXiu1lLX2P9Ly9xa4gHJgLeR1uGN5qegUobtGo"></script>

    
</body>
```
➡ The WebApp content is returned, and the traffic goes through the private link.  
Source: trust me bro. I deleted my lab after getting the evidence, but since the public IP for the WebApp was disabled ... 🤷‍♀️