#!/bin/bash

# Script de déploiement automatisé pour l'infrastructure Azure Terraform
# Auteur: FIENI DANNIE INNOCENT JUNIOR
# Formation: Mastère 1 Cybersécurité & Cloud Computing - IPSSI Nice

set -e  # Arrêt en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    print_message "Vérification des prérequis..."
    
    # Vérification d'Azure CLI
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI n'est pas installé"
        exit 1
    fi
    
    # Vérification de Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform n'est pas installé"
        exit 1
    fi
    
    # Vérification de la connexion Azure
    if ! az account show &> /dev/null; then
        print_error "Vous n'êtes pas connecté à Azure. Exécutez 'az login'"
        exit 1
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Fonction pour obtenir l'IP publique
get_public_ip() {
    print_message "Récupération de votre IP publique..."
    PUBLIC_IP=$(curl -s ifconfig.me)
    if [ -z "$PUBLIC_IP" ]; then
        print_warning "Impossible de récupérer l'IP publique automatiquement"
        read -p "Entrez votre IP publique: " PUBLIC_IP
    fi
    print_success "IP publique détectée: $PUBLIC_IP"
}

# Fonction pour mettre à jour terraform.tfvars
update_tfvars() {
    print_message "Mise à jour du fichier terraform.tfvars..."
    
    # Sauvegarde du fichier original
    cp terraform.tfvars terraform.tfvars.bak
    
    # Mise à jour de l'IP
    sed -i "s/my_ip_address = \"0.0.0.0\/0\"/my_ip_address = \"$PUBLIC_IP\/32\"/" terraform.tfvars
    
    print_success "Fichier terraform.tfvars mis à jour avec l'IP: $PUBLIC_IP/32"
}

# Fonction pour initialiser Terraform
terraform_init() {
    print_message "Initialisation de Terraform..."
    terraform init
    print_success "Terraform initialisé"
}

# Fonction pour formater le code
terraform_format() {
    print_message "Formatage du code Terraform..."
    terraform fmt
    print_success "Code formaté"
}

# Fonction pour valider la syntaxe
terraform_validate() {
    print_message "Validation de la syntaxe Terraform..."
    terraform validate
    print_success "Syntaxe valide"
}

# Fonction pour planifier le déploiement
terraform_plan() {
    print_message "Planification du déploiement..."
    terraform plan -out=tfplan
    print_success "Plan généré avec succès"
}

# Fonction pour appliquer le déploiement
terraform_apply() {
    print_message "Déploiement de l'infrastructure..."
    terraform apply tfplan
    print_success "Infrastructure déployée avec succès"
}

# Fonction pour afficher les outputs
show_outputs() {
    print_message "Informations de connexion:"
    echo "=================================="
    terraform output
    echo "=================================="
    
    # Sauvegarde des outputs dans un fichier
    terraform output > deployment_info.txt
    print_success "Informations sauvegardées dans deployment_info.txt"
}

# Fonction pour tester la connectivité
test_connectivity() {
    print_message "Test de connectivité..."
    
    # Récupération de l'IP publique de la VM
    VM_IP=$(terraform output -raw public_ip_address)
    
    if [ -z "$VM_IP" ]; then
        print_error "Impossible de récupérer l'IP de la VM"
        return 1
    fi
    
    print_message "IP de la VM: $VM_IP"
    
    # Test ping
    print_message "Test ping vers $VM_IP..."
    if ping -c 3 $VM_IP &> /dev/null; then
        print_success "Ping réussi"
    else
        print_warning "Ping échoué (peut être normal si ICMP est bloqué)"
    fi
    
    # Test SSH (avec timeout)
    print_message "Test de connexion SSH..."
    if timeout 10 ssh -i ssh_key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 azureuser@$VM_IP "echo 'SSH OK'" &> /dev/null; then
        print_success "Connexion SSH réussie"
    else
        print_warning "Connexion SSH échouée (la VM peut encore être en cours d'initialisation)"
    fi
    
    # Test HTTP
    print_message "Test du serveur web..."
    if timeout 10 curl -s http://$VM_IP &> /dev/null; then
        print_success "Serveur web accessible"
    else
        print_warning "Serveur web non accessible (peut être en cours d'initialisation)"
    fi
}

# Fonction pour nettoyer les fichiers temporaires
cleanup() {
    print_message "Nettoyage des fichiers temporaires..."
    rm -f tfplan
    print_success "Nettoyage terminé"
}

# Fonction pour afficher les instructions finales
show_instructions() {
    echo ""
    echo "=================================="
    echo "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS!"
    echo "=================================="
    echo ""
    echo "Pour vous connecter à votre VM:"
    echo "1. SSH: $(terraform output -raw ssh_connection_command)"
    echo "2. Web: $(terraform output -raw web_server_url)"
    echo ""
    echo "Fichiers importants:"
    echo "- ssh_key.pem: Clé SSH privée (gardez-la secrète!)"
    echo "- deployment_info.txt: Informations de déploiement"
    echo ""
    echo "Pour détruire l'infrastructure:"
    echo "terraform destroy"
    echo ""
    echo "=================================="
}

# Fonction principale
main() {
    echo "=================================="
    echo "🚀 DÉPLOIEMENT INFRASTRUCTURE AZURE"
    echo "=================================="
    echo "Étudiant: FIENI DANNIE INNOCENT JUNIOR"
    echo "Formation: Mastère 1 Cybersécurité & Cloud Computing"
    echo "École: IPSSI Nice"
    echo "=================================="
    echo ""
    
    # Confirmation avant déploiement
    read -p "Voulez-vous continuer le déploiement? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Déploiement annulé"
        exit 0
    fi
    
    # Exécution des étapes
    check_prerequisites
    get_public_ip
    update_tfvars
    terraform_init
    terraform_format
    terraform_validate
    terraform_plan
    terraform_apply
    show_outputs
    
    # Attente pour que la VM se termine d'initialiser
    print_message "Attente de l'initialisation de la VM (60 secondes)..."
    sleep 60
    
    test_connectivity
    cleanup
    show_instructions
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Afficher cette aide"
    echo "  -t, --test     Exécuter uniquement les tests"
    echo "  -d, --destroy  Détruire l'infrastructure"
    echo "  -p, --plan     Exécuter uniquement la planification"
    echo ""
    echo "Exemples:"
    echo "  $0              Déploiement complet"
    echo "  $0 --test       Tests uniquement"
    echo "  $0 --destroy    Destruction de l'infrastructure"
}

# Fonction pour détruire l'infrastructure
destroy_infrastructure() {
    print_warning "ATTENTION: Vous allez détruire toute l'infrastructure!"
    read -p "Êtes-vous sûr? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Destruction annulée"
        exit 0
    fi
    
    print_message "Destruction de l'infrastructure..."
    terraform destroy -auto-approve
    print_success "Infrastructure détruite"
    
    # Nettoyage des fichiers locaux
    rm -f ssh_key.pem deployment_info.txt
    print_success "Fichiers locaux nettoyés"
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -t|--test)
        test_connectivity
        exit 0
        ;;
    -d|--destroy)
        destroy_infrastructure
        exit 0
        ;;
    -p|--plan)
        check_prerequisites
        terraform_init
        terraform_format
        terraform_validate
        terraform_plan
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Option inconnue: $1"
        show_help
        exit 1
        ;;
esac