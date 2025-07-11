# IP publique de la VM
output "public_ip_address" {
  description = "Public IP address of the Virtual Machine"
  value       = azurerm_public_ip.main.ip_address
}

# FQDN de la VM
output "fqdn" {
  description = "Fully Qualified Domain Name of the Virtual Machine"
  value       = azurerm_public_ip.main.fqdn
}

# Nom du Resource Group
output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

# Commande SSH pour se connecter
output "ssh_connection_command" {
  description = "SSH command to connect to the Virtual Machine"
  value       = "ssh -i ssh_key.pem ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

# URL du serveur web
output "web_server_url" {
  description = "URL of the web server"
  value       = "http://${azurerm_public_ip.main.ip_address}"
}

# Informations sur la VM
output "vm_info" {
  description = "Virtual Machine information"
  value = {
    name           = azurerm_linux_virtual_machine.main.name
    size           = azurerm_linux_virtual_machine.main.size
    location       = azurerm_linux_virtual_machine.main.location
    admin_username = azurerm_linux_virtual_machine.main.admin_username
  }
}

# Informations réseau
output "network_info" {
  description = "Network configuration information"
  value = {
    vnet_name             = azurerm_virtual_network.main.name
    vnet_address_space    = azurerm_virtual_network.main.address_space
    subnet_name           = azurerm_subnet.public.name
    subnet_address_prefix = azurerm_subnet.public.address_prefixes[0]
    nsg_name              = azurerm_network_security_group.main.name
  }
}

# Clé SSH publique (pour référence)
output "ssh_public_key" {
  description = "SSH public key for the Virtual Machine"
  value       = tls_private_key.ssh_key.public_key_openssh
  sensitive   = false
}

# Instructions de connexion complètes
output "connection_instructions" {
  description = "Complete instructions to connect to the VM"
  value       = <<-EOT
    1. Ensure the SSH private key has correct permissions: chmod 600 ssh_key.pem
    2. Connect via SSH: ssh -i ssh_key.pem ${var.admin_username}@${azurerm_public_ip.main.ip_address}
    3. Access web server: http://${azurerm_public_ip.main.ip_address}
    4. Test connectivity: ping ${azurerm_public_ip.main.ip_address}
  EOT
}