## Deploy and manage Azure compute resources

### Automate deployment of resources by using Azure Resource Manager templates or Bicep files
  #### Interpret an ARM template or Bicep file
  - [Comparing JSON and Bicep for templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/compare-template-syntax)

  #### Modify an existing ARM template
  - [What are ARM templates ?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)
  - [Modify an existing ARM template](https://www.bdrshield.com/blog/az-104-modify-an-existing-azure-resource-manager-template/)
  - [Create ARM template - VSCode](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code?tabs=CLI)
  - [Create ARM template - Azure Portal](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-the-portal)

  #### Modify an existing Bicep file
  - [What is Bicep ?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
  - [Modify an Existing Azure Bicep file](https://www.bdrshield.com/blog/az-104-modify-an-existing-azure-bicep-file-part-39/)
  
  #### Deploy resources by using ARM template or a Bicep file
  - [Deploy Bicep files - PowerShell](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-powershell)
  - [Deploy arm files - CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli)
  - [Deploy ARM templates - PowerShell](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell)
  - [Deploy ARM templates - CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli)
  
  #### Export a deployment as an ARM template or convert an ARM template to a Bicep file
  - [Export ARM template](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template-portal)
  - [Export Bicep file](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/export-bicep-portal)
  - [Migrate Azure resources and JSON ARM templates to use Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/migrate)
---

### Create and configure virtual machines
  #### Create a virtual machine
  - [Create and Manage Linux VMs with the Azure CLI](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-vm)
  - [Create and Manage Windows VMs with Azure PowerShell](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-vm)
  
  #### Configure Azure Disk Encryption
  - [Disk encryption overview](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
  - [Azure Disk Encryption for Linux VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-overview)
  - [Azure Disk Encryption for Windows VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview)
  
  #### Move a virtual machine to an other resource group, subscription, or region
  - [Move Azure resources to a new resource group or subscription](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription?tabs=azure-cli)
  - [Handling special cases when moving virtual machines to resource group or subscriptionxt](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-limitations/virtual-machines-move-limitations?tabs=azure-cli)

  #### Manage virtual machine size
  - [Sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist)
  - [Change the size of a virtual machinet](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/resize-vm?tabs=portal)
  
  #### Manage virtual machine disks
  - [Introduction to Azure managed disks](https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview)
  - [Azure managed disk types](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types)
  
  #### Deploy virtual machines to availability zones and availabitlity sets
  - [Availability zones overview](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?toc=%2Fazure%2Fvirtual-machines%2Ftoc.json&tabs=azure-cli)
  - [Availability sets overview](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)
  
  #### Deploy and configure an Azure Virtual Scale Sets
  - [Virtual Machine Scale Sets overview](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview)
  - [Create virtual machines in a scale set - PowerShell](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/flexible-virtual-machine-scale-sets-powershell?toc=%2Fazure%2Fvirtual-machines%2Ftoc.json)
  - [Create virtual machines in a scale set - Azure CLI](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/flexible-virtual-machine-scale-sets-cli?toc=%2Fazure%2Fvirtual-machines%2Ftoc.json)
  
---

### Provision and manage containers in the Azure Portal
  #### Create and manage an Azure Container registry
  - [Introduction to Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-intro)
  - [Create an Azure container registry - Azure portal](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-powershell)
  - [Create an Azure container registry - Powershell](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-powershell)
  - [Create an Azure container registry - CLI](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli)
  
  #### Provision a container by using Azure Container Instances
  - [Azure Container Instances overview](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-overview)
  - [Deploy a container instance in Azure - Azure portal](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart-portal)
  - [Deploy a container instance in Azure - PowerShell](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart-powershell)
  - [Deploy a container instance in Azure - CLI](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart)
  
  #### Provision a container by using Azure Container Apps
  - [Azure Container Apps overview](https://learn.microsoft.com/en-us/azure/container-apps/overview)
  
  #### Manage sizing and scaling for containers, including Azure Container Instances and Azure Container Apps
  - [Scaling with Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/scale-app?pivots=azure-cli)
  
---

### Create and configure Azure App Service
  #### Provision an App Service plan
  - [App Service plans overview](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
  
  #### Configure scaling for an App Service plan
  - [Scale up an app in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/manage-scale-up)
  - [Autoscale overview](https://learn.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-overview)
  
  #### Create an App Service
  - [Manage an App Service plan in Azure](https://learn.microsoft.com/en-us/azure/app-service/app-service-plan-manage)
  
  #### Configure certificates and Transport Layer Security (TLS) for an App Service
  - [Domain and cert quickstart](https://learn.microsoft.com/en-us/azure/app-service/tutorial-secure-domain-certificate)
  - [Overview of TLS/SSL in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview-tls)
  
  #### Map an existing custom DNS name to an App Service
  - [Overview of custom domains in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview-custom-domains)
  
  #### Configure backup for an App Service
  - [Back up and restore your app in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/manage-backup?tabs=portal)
  
  #### Configure networking settings for an App Service
  - [App Service networking features](https://learn.microsoft.com/en-us/azure/app-service/networking-features)
  
  #### Configure deployment slots for an App Service
  - [Set up staging environments in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots?tabs=portal)
  
---

### 🎞 Microsoft Learn Youtube videos
 - [Administer Virtual Machines, part 1](https://www.youtube.com/watch?v=m3RURyPJUJI)
 - [Administer Virtual Machines, part 2](https://www.youtube.com/watch?v=oaaMcbHsamk)
 - [Administer PaaS Compute options, part 1](https://www.youtube.com/watch?v=5clKdnQCb-0)
 - [Administer PaaS Compute options, part 2](https://www.youtube.com/watch?v=hyU8TnmxnV8)