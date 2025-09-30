### Install and configure Azure Powershell
➡ **On Powershell 7 and higher**

If needed, set the PowerShell execution policy to remote signed :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

Install the Az module :
```powershell
Install-Module -Name Az -Repository PSGallery -Force -Score AllUsers
```

First connection :  
```powershell
Connect-AzAccount
```

Doc on connection and contexts: https://learn.microsoft.com/en-us/powershell/azure/context-persistence?view=azps-14.4.0  

---
### List regions and locations

```powershell 
Get-AzLocation | select -Property displayname,location | sort -Property DisplayName
```

[Get-AzLocation doc](https://learn.microsoft.com/fr-fr/powershell/module/az.resources/get-azlocation?view=azps-14.4.0)

---
### List SKUs and VMs sizes

**Get-AzComputeResourceSku** Command example to get VMs sizes et capabilities for the "francecentral" region:  
```powershell
Get-AzComputeResourceSku `
    | Where-Object { $_.ResourceType -eq 'virtualMachines' -and $_.Locations -contains 'francecentral' } `
    | Select-Object Name, @{Name="Capabilities"; Expression={$_.Capabilities | Select-Object Name, Value}}

# With the result of this command stored into the $yolo var, get the capabilities for the "Standard_B2s_v2" size
($yolo | ?{$_.Name -eq "Standard_B2s_v2"}).Capabilities
```

Output :  
```
Name                                         Value
----                                         -----
MaxResourceVolumeMB                          0
OSVhdSizeMB                                  1047552
vCPUs                                        2
MemoryPreservingMaintenanceSupported         True
HyperVGenerations                            V1,V2
SupportedCapacityReservationTypes            Targeted
MemoryGB                                     8
MaxDataDiskCount                             4
CpuArchitectureType                          x64
LowPriorityCapable                           True
HibernationSupported                         True
PremiumIO                                    True
VMDeploymentTypes                            IaaS
vCPUsAvailable                               2
vCPUsPerCore                                 2
CombinedTempDiskAndCachedIOPS                9000
CombinedTempDiskAndCachedReadBytesPerSecond  125000000
CombinedTempDiskAndCachedWriteBytesPerSecond 125000000
UncachedDiskIOPS                             3750
UncachedDiskBytesPerSecond                   85000000
EphemeralOSDiskSupported                     False
EncryptionAtHostSupported                    True
CapacityReservationSupported                 False
AcceleratedNetworkingEnabled                 True
RdmaEnabled                                  False
MaxNetworkInterfaces                         2
```
<br>

Simple function to retrieve Standards SKUs in a given location, sorted by amount of vCPUs and RAM.
```powershell
function Get-VMSKU 
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$true)]
        [string]$Location,

        [Parameter(Mandatory=$false)]
        [int]$MinCPUs = 1,

        [parameter(Mandatory=$false)]
        [int]$MinRAM = 0,

        [parameter(Mandatory=$false)]
        [ValidateSet("Name", "vCPUs", "RAM")]
        [string[]]$SortBy = "Name"
    )
    
    Get-AzComputeResourceSku -Location $Location | Where-Object `
    {
        $_.Name -like 'Standard_*' -and
        ([int]($_.Capabilities | Where-Object { $_.Name -eq 'vCPUs' }).Value) -ge $MinCPUs -and
        ([int]($_.Capabilities | Where-Object { $_.Name -eq 'MemoryGB' }).Value) -ge $MinRAM
    }
    | Select-Object -Property Name,
        @{Name = 'vCPUs'; Expression = { [int]($_.Capabilities | Where-Object { $_.Name -eq 'vCPUs' }).Value }},
        @{Name = 'RAM'; Expression = { ([int]($_.Capabilities | Where-Object { $_.Name -eq 'MemoryGB' }).Value) }}
    | Sort-Object -Property $SortBy
}

# Getting VM sizes for francentral, with 4 and 8 or more CPU and RAM. Sorting by CPUs and RAM
Get-VMSKU -Location "francecentral" -MinCPUs 4 -MinRAM 8 -SortBy @('vCPUs','RAM')
```
Output :
```
Name                       vCPUs  RAM
----                       ---- - -- -
Standard_F4s                   4    8
[...]
Standard_D4alds_v6             4    8
Standard_A4_v2                 4    8
Standard_D4als_v6              4    8
Standard_D3                    4   14
Standard_DS3_v2_Promo          4   14
[...]
Standard_NV4as_v4              4   14
Standard_D4s_v3                4   16
Standard_D4ps_v5               4   16
Standard_D4_v5                 4   16
[...]
Standard_A6                    4   28
Standard_DS12_v2_Promo         4   28
Standard_DS12_v2               4   28
```

[Get-AzComputeResourceSku doc](https://learn.microsoft.com/en-us/powershell/module/az.compute/get-azcomputeresourcesku?view=azps-14.4.0)  
[Get-AzVMSize doc](https://https://learn.microsoft.com/en-us/powershell/module/az.compute/get-azvmsize?view=azps-14.4.0)

---
### List VM Images

Publisher alias for Linux VMs (most commonly used) :
- Debian
- RedHat
- Canonical

Publisher alias for Windows VMs :
- Server : MicrosoftWindowsServer  
- Desktop : MicrosoftVisualStudio   

#### List images :   

```powershell

$locName="francecentral"
Get-AzVMImagePublisher -Location $locName | Select PublisherName

$pubName="Canonical"
Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select Offer

$offerName="ubuntu-22_04-lts"
Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select Skus

$skuName="server"
Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Sku $skuName
```

[Find and use Azure Marketplace VM images with Azure PowerShell](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage)  

---
### Add SSH key to Azure as a resource

In this example, I'm adding my public key located on my machine on **~/.ssh/id_rsa.pub** , to my **network_lab1** resource group.

```powershell
$ssh = @{
    PublicKey = $(Get-Content -Path "~/.ssh/id_rsa.pub" -Raw)
    Name = "sshkey_lolecat"
    ResourceGroupName = "network_lab1"
}

New-AzSshKey @ssh
```
[New-AzSshKey doc](https://learn.microsoft.com/fr-fr/powershell/module/az.compute/new-azsshkey?view=azps-14.4.0)  

---
### Get Subnets for a specified Virtual Network

```powershell
function Get-AzVirtualSubnets
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true )]
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$VirtualNetwork
    )

    try 
    {
        if ($VirtualNetwork.Subnets -and $VirtualNetwork.Subnets.Count -gt 0) 
        {
            $VirtualNetwork.Subnets | % `
            {
                [PSCustomObject]@{
                    Name              = $_.Name
                    AddressPrefix     = $_.AddressPrefix -join ", "
                    Id                = $_.Id
                    ProvisioningState = $_.ProvisioningState
                    VNetName          = $VirtualNetwork.Name
                    ResourceGroupName = $VirtualNetwork.ResourceGroupName
                }
            }
        }

        elseif ($VirtualNetwork.SubnetsText) 
        {
            $subnets = $VirtualNetwork.SubnetsText | ConvertFrom-Json
            if ($subnets -and $subnets.Count -gt 0) 
            {
                $subnets | % `
                {
                    [PSCustomObject]@{
                        Name              = $_.Name
                        AddressPrefix     = $_.AddressPrefix -join ", "
                        Id                = $_.Id
                        ProvisioningState = $_.ProvisioningState
                        VNetName          = $VirtualNetwork.Name
                        ResourceGroupName = $VirtualNetwork.ResourceGroupName
                    }
                }
            }

            else { Write-Warning "No subnets found in SubnetsText for Virtual Network: $($VirtualNetwork.Name)" }
        }

        else { Write-Warning "No subnets found for Virtual Network: $($VirtualNetwork.Name)" }
    }

    catch { Write-Error "Failed to process subnets for Virtual Network: $($VirtualNetwork.Name). Error: $_" }
}

$test = Get-AzVirtualNetwork -ResourceGroupName "network_lab2"
$test | Get-AzVirtualSubnets
```

Output :
```
Name              : subnet-ag
AddressPrefix     : 192.168.33.0/24
Id                : /subscriptions/<...>/network_lab2/providers/Microsoft.Network/virtualNetworks/vnet-2/subnets/subnet-ag
ProvisioningState : Succeeded
VNetName          : vnet-2
ResourceGroupName : network_lab2

Name              : subnet-vm
AddressPrefix     : 192.168.40.0/24
Id                : /subscriptions/<...>/resourceGroups/network_lab2/providers/Microsoft.Network/virtualNetworks/vnet-2/subnets/subnet-vm
ProvisioningState : Succeeded
VNetName          : vnet-2
ResourceGroupName : network_lab2
```
---
### Testing purposes : remove pasphrase from a private key

You can easily remove passphrase of a key by using the following command :
```
ssh-keygen -p
```

- On the first prompt, enter the file path (or press Enter to use the default)
- Second prompt, enter the old passphrase
- Next prompt, just press enter to unset the passphrase

---