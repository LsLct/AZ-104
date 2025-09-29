https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-powershell

We'll deploy the following architecture with Powershell:

![schema](../.imgs/network_lab2.png "schema")

---

### 1/ Resource group

```powershell
New-AzResourceGroup -Name "network_lab2" -Location "francecentral"
```  

Output :
```
ResourceGroupName : network_lab2
Location          : francecentral
ProvisioningState : Succeeded
Tags              :
ResourceId        : /subscriptions/<...>/resourceGroups/network_lab2
``` 

### 2/ Virtual network and subnet

```powershell
# Create the virtual network
$vnet = @{
    Name = 'vnet-2'
    ResourceGroupName = 'network_lab2'
    Location = 'francecentral'
    AddressPrefix = '192.168.0.0/16'
}

$virtualNetwork = New-AzVirtualNetwork @vnet

# Create the subnets in the previously created virtual network
$subnet = @{
    Name = 'subnet-ag'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.33.0/24'
}

$subnetAG = Add-AzVirtualNetworkSubnetConfig @subnet

$subnet = @{
    Name = 'subnet-vm'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.40.0/24'
}

$subnetVM = Add-AzVirtualNetworkSubnetConfig @subnet

# Apply the subnets configuration to the virtual network
$virtualNetwork | Set-AzVirtualNetwork

```  

Output :
``` 
$virtualNetwork | fl -Property Name, ResourceGroupName,Location, ProvisioningState, Type, Subnets

Name              : vnet-2
ResourceGroupName : network_lab2
Location          : francecentral
ProvisioningState : Succeeded
Type              : Microsoft.Network/virtualNetworks
Subnets           : {subnet-ag, subnet-vm}
```

### 3/ Backend servers / VMs

### 4/ Application Gateway







########################################
########################################


1 - Créer l'Availibility Set  
```powershell
$as = @{
    Name = 'av-set1'
    ResourceGroupName = 'network_lab2'
    Location = 'francecentral'
    PlatformUpdateDomainCount = 2
    PlatformFaultDomainCount = 2
}
$avSet = New-AzAvailabilitySet @as

```
New-Az

2 - Créer les VMs dans l'AZ  


3 - Créer le serveur temporaire  








