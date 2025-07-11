# TP Terraform Solo - Azure Infrastructure de Base

## 👨‍🎓 Informations de l'étudiant
- **Nom**: FIENI DANNIE INNOCENT JUNIOR
- **Formation**: Mastère 1 Cybersécurité & Cloud Computing
- **École**: IPSSI Nice
- **Projet**: Infrastructure Azure avec Terraform

## 📋 Description du projet
Ce projet consiste à déployer une infrastructure Azure simple et fonctionnelle en utilisant Terraform. L'infrastructure comprend une machine virtuelle Linux Ubuntu 22.04 avec un serveur web Nginx, accessible via SSH et HTTP.

## 🏗️ Architecture déployée
```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Group                           │
│                 rg-terraform-dev                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                Virtual Network                          ││
│  │                vnet-dev (10.0.0.0/16)                  ││
│  │                                                         ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │              Subnet Public                          │││
│  │  │           subnet-public (10.0.1.0/24)              │││
│  │  │                                                     │││
│  │  │  ┌─────────────┐    ┌─────────────┐                │││
│  │  │  │     VM      │    │     NSG     │                │││
│  │  │  │vm-webserver │    │nsg-webserver│                │││
│  │  │  │Ubuntu 22.04 │    │SSH:22/HTTP  │                │││
│  │  │  │Standard_B1s │    │    :80      │                │││
│  │  │  └─────────────┘    └─────────────┘                │││
│  │  │          │                                          │││
│  │  │          │                                          │││
│  │  │  ┌─────────────┐                                    │││
│  │  │  │ Public IP   │                                    │││
│  │  │  │pip-webserver│                                    │││
│  │  │  └─────────────┘                                    │││
│  │  └─────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## 📦 Composants déployés
- **Resource Group**: `rg-terraform-dev`
- **Virtual Network**: `vnet-dev` (10.0.0.0/16)
- **Subnet**: `subnet-public` (10.0.1.0/24)
- **Virtual Machine**: `vm-webserver` (Ubuntu 22.04 LTS, Standard_B1s)
- **Public IP**: `pip-webserver`
- **Network Security Group**: `nsg-webserver`
- **SSH Key Pair**: Générée automatiquement

## 🛠️ Prérequis
### Logiciels requis
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- Git
- Un compte Azure avec des crédits disponibles

### Vérification des prérequis
```bash
# Vérifier Azure CLI
az --version

# Vérifier Terraform
terraform --version

# Vérifier Git
git --version
```

## 🚀 Installation et déploiement

### 1. Clone du repository
```bash
git clone https://github.com/JuFiSec/terraform-azure-solo.git
cd terraform-azure-solo
```

### 2. Connexion à Azure
```bash
# Connexion à Azure
az login

# Vérifier la souscription active
az account show

# (Optionnel) Changer de souscription
az account set --subscription "VOTRE_SUBSCRIPTION_ID"
```

### 3. Configuration des variables
Modifiez le fichier `terraform.tfvars` avec vos valeurs :

```bash
# Obtenir votre IP publique
curl ifconfig.me

# Éditer le fichier terraform.tfvars
nano terraform.tfvars
```

⚠️ **IMPORTANT**: Remplacez `my_ip_address = "0.0.0.0/0"` par votre IP réelle (format: "VOTRE_IP/32")

### 4. Déploiement de l'infrastructure
```bash
# Initialisation de Terraform
terraform init

# Formatage du code
terraform fmt

# Validation de la syntaxe
terraform validate

# Planification des changements
terraform plan

# Application des changements
terraform apply
```

Tapez `yes` quand Terraform vous demande confirmation.

### 5. Récupération des informations de connexion
```bash
# Afficher toutes les sorties
terraform output

# Afficher la commande SSH
terraform output ssh_connection_command

# Afficher l'URL du serveur web
terraform output web_server_url
```

## 🔐 Connexion à la VM

### Via SSH
```bash
# Donner les bonnes permissions à la clé SSH
chmod 600 ssh_key.pem

# Se connecter à la VM
ssh -i ssh_key.pem azureuser@VOTRE_IP_PUBLIQUE
```

### Via le navigateur web
Ouvrez votre navigateur et allez à : `http://VOTRE_IP_PUBLIQUE`

## 🧪 Tests de validation

### Test de connectivité
```bash
# Test ping
ping VOTRE_IP_PUBLIQUE

# Test SSH
ssh -i ssh_key.pem azureuser@VOTRE_IP_PUBLIQUE "echo 'Connexion SSH réussie'"

# Test HTTP
curl -I http://VOTRE_IP_PUBLIQUE
```

### Test des services
```bash
# Se connecter à la VM
ssh -i ssh_key.pem azureuser@VOTRE_IP_PUBLIQUE

# Vérifier le serveur web
sudo systemctl status nginx

# Vérifier les ports ouverts
sudo ss -tulpn | grep -E ':80|:22'
```

## 🗑️ Nettoyage des ressources

### Destruction de l'infrastructure
```bash
# Détruire toutes les ressources
terraform destroy
```

Tapez `yes` quand Terraform vous demande confirmation.

### Nettoyage des fichiers locaux
```bash
# Supprimer les fichiers temporaires
rm -f ssh_key.pem
rm -f terraform.tfstate*
rm -rf .terraform/
```

## 📊 Coûts estimés
- **VM Standard_B1s**: ~15€/mois
- **Public IP**: ~3€/mois
- **Stockage Standard SSD 30GB**: ~3€/mois
- **Bande passante**: Variable selon utilisation

**Total estimé**: ~21€/mois

## 🔧 Troubleshooting

### Erreurs communes

#### 1. Erreur d'authentification
```bash
Error: building AzureRM Client: authentication failed
```
**Solution**: Vérifiez votre connexion Azure
```bash
az login
az account show
```

#### 2. Erreur de permissions
```bash
Error: insufficient privileges to complete the operation
```
**Solution**: Vérifiez vos permissions sur la souscription Azure

#### 3. Erreur de quota
```bash
Error: quota exceeded
```
**Solution**: Vérifiez vos quotas Azure ou changez de région

#### 4. Erreur de nommage
```bash
Error: resource name already exists
```
**Solution**: Changez les noms dans `terraform.tfvars`

### Commandes utiles de débogage
```bash
# Vérifier l'état Terraform
terraform state list

# Afficher les détails d'une ressource
terraform state show azurerm_linux_virtual_machine.main

# Rafraîchir l'état
terraform refresh

# Importer une ressource existante
terraform import azurerm_resource_group.main /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME
```

## 📚 Ressources utiles
- [Documentation Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Documentation officielle Terraform](https://www.terraform.io/docs/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Tailles des VMs Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)

## 🤝 Support
Pour toute question ou problème :
1. Consultez la section Troubleshooting
2. Vérifiez les logs Azure : `az monitor activity-log list`
3. Consultez la documentation officielle
4. Contactez le support Azure si nécessaire

## 📄 Licence
Ce projet est réalisé dans le cadre d'un TP pédagogique à l'IPSSI Nice.

---
**Réalisé par**: FIENI DANNIE INNOCENT JUNIOR  
**Formation**: Mastère 1 Cybersécurité & Cloud Computing  
**École**: IPSSI Nice  
**Date**: 2025
