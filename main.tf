# Configuration Terraform et provider Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configuration du provider Azure
provider "azurerm" {
  features {}
}

# Génération d'une paire de clés SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sauvegarde de la clé privée localement
resource "local_file" "ssh_private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ssh_key.pem"

  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/ssh_key.pem"
  }
}

# Resource Group principal
resource "azurerm_resource_group" "main" {
  name     = "rg-terraform-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.common_tags
}

# Subnet public
resource "azurerm_subnet" "public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP publique pour la VM
resource "azurerm_public_ip" "main" {
  name                = "pip-webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.common_tags
}

# Network Security Group avec règles de sécurité
resource "azurerm_network_security_group" "main" {
  name                = "nsg-webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.common_tags

  # Règle SSH - accès depuis votre IP uniquement
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_address
    destination_address_prefix = "*"
  }

  # Règle HTTP - accès depuis internet
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Règle HTTPS - accès depuis internet (bonus)
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Interface réseau pour la VM
resource "azurerm_network_interface" "main" {
  name                = "nic-webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Association du NSG à l'interface réseau
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Virtual Machine Linux
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.common_tags

  # Désactiver l'authentification par mot de passe
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Script d'initialisation pour installer un serveur web (bonus)
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Serveur Web - TP Terraform Azure</h1>" > /var/www/html/index.html
              echo "<p>Créé par: FIENI DANNIE INNOCENT JUNIOR</p>" >> /var/www/html/index.html
              echo "<p>Mastère 1 Cybersécurité & Cloud Computing IPSSI Nice</p>" >> /var/www/html/index.html
              echo "<p>Date de déploiement: $(date)</p>" >> /var/www/html/index.html
              EOF
  )
}