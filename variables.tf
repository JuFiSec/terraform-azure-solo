# Variable pour la région Azure
variable "location" {
  description = "Azure region for resources deployment"
  type        = string
  default     = "France Central"

  validation {
    condition     = can(regex("^[A-Za-z ]+$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

# Variable pour l'environnement
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

# Variable pour la taille de la VM
variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must be a valid Azure VM size starting with 'Standard_'."
  }
}

# Variable pour le nom d'utilisateur SSH
variable "admin_username" {
  description = "SSH username for the Virtual Machine"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters."
  }
}

# Variable pour votre adresse IP (sécurité SSH)
variable "my_ip_address" {
  description = "Your public IP address for SSH access restriction"
  type        = string
  default     = "0.0.0.0/0" # À remplacer par votre IP réelle

  validation {
    condition     = can(cidrnetmask(var.my_ip_address))
    error_message = "Must be a valid IP address in CIDR notation (e.g., 192.168.1.1/32)."
  }
}

# Variable pour le nom du projet
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-azure-tp"
}

# Variable pour le propriétaire
variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "FIENI DANNIE INNOCENT JUNIOR"
}

# Tags communs à toutes les ressources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-azure-tp"
    Owner       = "FIENI DANNIE INNOCENT JUNIOR"
    CreatedBy   = "terraform"
    School      = "IPSSI Nice"
    Course      = "Mastère 1 Cybersécurité & Cloud Computing"
  }
}