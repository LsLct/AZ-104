https://learn.microsoft.com/en-us/azure/virtual-network/quickstart-create-virtual-network?tabs=portal

We'll deploy the following architecture with Powershell:

![schema](../.imgs/network_lab1.png "schema")

➡ Two virtual machines and an Azure Bastion host are deployed to test connectivity between the virtual machines in the same virtual network.  
The Azure Bastion host facilitates secure and seamless SSH connectivity to the virtual machines directly in the Azure portal over SSL.  


Cmdlets used in this lab:
- [New-AzVirtualNetwork](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azvirtualnetwork)
- [Add-AzVirtualNetworkSubnetConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/add-azvirtualnetworksubnetconfig)
- [Set-AzVirtualNetwork](https://learn.microsoft.com/en-us/powershell/module/az.network/set-azvirtualnetwork)
- [New-AzPublicIpAddress](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azpublicipaddress)
- [New-AzVM](https://learn.microsoft.com/en-us/powershell/module/az.compute/new-azvm)


---
### 1/ Resource group

```powershell
New-AzResourceGroup -Name "network_lab1" -Location "francecentral"
```  

Output :
```
ResourceGroupName : network_lab1
Location          : francecentral
ProvisioningState : Succeeded
Tags              :
ResourceId        : /subscriptions/<...>/resourceGroups/network_lab1
``` 

### 2/ Virtual network and subnet

```powershell
# Create the virtual network
$vnet = @{
    Name = 'vnet-1'
    ResourceGroupName = 'network_lab1'
    Location = 'francecentral'
    AddressPrefix = '192.168.0.0/16'
}

$virtualNetwork = New-AzVirtualNetwork @vnet

# Create the subnet in the previously created virtual network
$subnet = @{
    Name = 'subnet-1'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.40.0/24'
}

$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet

# Apply the subnet configuration to the virtual network
$virtualNetwork | Set-AzVirtualNetwork

```  

Output :
``` 
$virtualNetwork | fl -Property Name, ResourceGroupName,Location, ProvisioningState, Type, SubnetText

Name              : vnet-1
ResourceGroupName : network_lab1
Location          : francecentral
ProvisioningState : Succeeded
Type              : Microsoft.Network/virtualNetworks
SubnetsText       : [
                      {
                        "Name": "subnet-1",
                        "AddressPrefix": [
                          "192.168.40.0/24"
                        ],
                        "PrivateEndpointNetworkPolicies": "Disabled",
                        "PrivateLinkServiceNetworkPolicies": "Enabled"
                      }
                    ]

```  

### 3/ Azure Bastion

```powershell
# Create the bastion subnet
$bastion_subnet = @{
    Name = 'AzureBastionSubnet' # The subnet name must be this one. It lets Azure know which subnet to deploy the Bastion resources to
    VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName "network_lab1" -Name "vnet-1"
    AddressPrefix = '192.168.1.0/26' # /26 is the minimum IP range (or maximum subnet mask) for a Bastion deployment.
}
$bastion_subnetConfig = Add-AzVirtualNetworkSubnetConfig @bastion_subnet

# Apply the subnet configuration to the virtual network
Get-AzVirtualNetwork -ResourceGroupName "network_lab1" -Name "vnet-1" | Set-AzVirtualNetwork

# Create a public IP
$ip = @{
        ResourceGroupName = 'network_lab1'
        Name = 'public-ip'
        Location = 'francecentral'
        AllocationMethod = 'Static'
        Sku = 'Standard'
        Zone = 1,2,3
}

New-AzPublicIpAddress @ip

# Create the Bastion host
$bastion = @{
    Name = 'bastion'
    ResourceGroupName = 'network_lab1'
    PublicIpAddressRgName = 'network_lab1'
    PublicIpAddressName = 'public-ip'
    VirtualNetworkRgName = 'network_lab1'
    VirtualNetworkName = 'vnet-1'
    Sku = 'Basic'
}

New-AzBastion @bastion
```

Output :
```
Get-AzBastion -ResourceGroupName "network_lab1" -Name "bastion" | fl ResourceGroupName, Name, Location, ProvisioningState, Type

ResourceGroupName : network_lab1
Name              : bastion
Location          : francecentral
ProvisioningState : Succeeded
Type              : Microsoft.Network/bastionHosts
```  

### 4/ VMs

```powershell
foreach ($i in 1..2) `
{
    $vnet = Get-AzVirtualNetwork -Name 'vnet-1' -ResourceGroupName 'network_lab1'
    $securePassword = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
    $user = "louis"
    $cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword)

    ## Create a network interface for the virtual machine.
    $nic = @{
        Name              = "vm{0}-nic1" -f $i
        ResourceGroupName = 'network_lab1'
        Location          = 'francecentral'
        Subnet            = $vnet.Subnets | ?{$_.Name -eq 'subnet-1'}
    }

    $nicVM = New-AzNetworkInterface @nic

    ## Create a virtual machine configuration.
    $vmsz = @{
        VMName = "vm{0}" -f $i
        VMSize = 'Standard_B2s_v2'  
    }

    $vmos = @{
        ComputerName = "vm{0}" -f $i
        Credential   = $cred
        DisablePasswordAuthentication = $true
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
        | Add-AzVMNetworkInterface -Id $nicVM.Id

    ## Create the virtual machine.
    $vm = @{
        ResourceGroupName = 'network_lab1'
        Location          = 'francecentral'
        SshKeyName        = 'sshkey_lolecat'
        VM                = $vmConfig
    }

    New-AzVM @vm
}
```

### 5/ Clean up

```powershell
Remove-AzResourceGroup -Name 'network_lab1' -Force
```
