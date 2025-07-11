#!/bin/bash

# Script de préparation pour GitHub
# Auteur: FIENI DANNIE INNOCENT JUNIOR
# Formation: Mastère 1 Cybersécurité & Cloud Computing - IPSSI Nice

set -e

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

# Fonction pour vérifier Git
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git n'est pas installé"
        exit 1
    fi
    print_success "Git est installé"
}

# Fonction pour vérifier GitHub CLI
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI n'est pas installé. Installation recommandée pour créer le repo automatiquement"
        return 1
    fi
    print_success "GitHub CLI est installé"
    return 0
}

# Fonction pour initialiser Git
init_git() {
    print_message "Initialisation du repository Git..."
    
    if [ ! -d ".git" ]; then
        git init
        print_success "Repository Git initialisé"
    else
        print_warning "Repository Git déjà initialisé"
    fi
}

# Fonction pour créer le fichier terraform.tfvars à partir du template
create_tfvars_from_template() {
    print_message "Création du fichier terraform.tfvars..."
    
    if [ ! -f "terraform.tfvars" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_success "Fichier terraform.tfvars créé à partir du template"
        print_warning "N'oubliez pas de modifier terraform.tfvars avec vos valeurs!"
    else
        print_warning "Le fichier terraform.tfvars existe déjà"
    fi
}

# Fonction pour créer la structure GitHub Actions
create_github_actions() {
    print_message "Création de la structure GitHub Actions..."
    
    mkdir -p .github/workflows
    print_success "Dossier .github/workflows créé"
}

# Fonction pour ajouter les fichiers à Git
add_files_to_git() {
    print_message "Ajout des fichiers au repository Git..."
    
    # Ajouter tous les fichiers sauf ceux dans .gitignore
    git add .
    print_success "Fichiers ajoutés à Git"
    
    # Vérifier le statut
    print_message "Statut du repository:"
    git status --short
}

# Fonction pour faire le premier commit
initial_commit() {
    print_message "Création du commit initial..."
    
    # Configuration Git si nécessaire
    if ! git config user.name &> /dev/null; then
        print_message "Configuration du nom Git..."
        read -p "Entrez votre nom pour Git: " git_name
        git config user.name "$git_name"
    fi
    
    if ! git config user.email &> /dev/null; then
        print_message "Configuration de l'email Git..."
        read -p "Entrez votre email pour Git: " git_email
        git config user.email "$git_email"
    fi
    
    # Créer le commit
    git commit -m "🚀 Initial commit: TP Terraform Azure Infrastructure

- Infrastructure Azure complète avec Terraform
- VM Ubuntu 22.04 avec Nginx
- Sécurité réseau configurée (NSG)
- Documentation complète
- Scripts d'automatisation
- CI/CD GitHub Actions

Étudiant: FIENI DANNIE INNOCENT JUNIOR
Formation: Mastère 1 Cybersécurité & Cloud Computing - IPSSI Nice"
    
    print_success "Commit initial créé"
}

# Fonction pour créer le repository GitHub
create_github_repo() {
    local repo_name="terraform-azure-solo"
    
    if check_gh_cli; then
        print_message "Création du repository GitHub avec GitHub CLI..."
        
        # Vérifier si l'utilisateur est connecté
        if ! gh auth status &> /dev/null; then
            print_message "Connexion à GitHub..."
            gh auth login
        fi
        
        # Créer le repository
        gh repo create "$repo_name" \
            --description "TP Terraform Azure - Infrastructure de base pour application web simple. Mastère 1 Cybersécurité & Cloud Computing - IPSSI Nice" \
            --public \
            --source=. \
            --remote=origin \
            --push
        
        print_success "Repository GitHub créé et code poussé!"
        print_message "URL du repository: https://github.com/$(gh api user --jq .login)/$repo_name"
    else
        print_warning "GitHub CLI non disponible. Création manuelle nécessaire."
        print_message "Étapes manuelles:"
        echo "1. Allez sur https://github.com/new"
        echo "2. Nom du repository: $repo_name"
        echo "3. Description: TP Terraform Azure - Infrastructure de base pour application web simple"
        echo "4. Public repository"
        echo "5. Créez le repository"
        echo "6. Suivez les instructions pour pousser le code existant"
    fi
}

# Fonction pour afficher les instructions post-setup
show_post_setup_instructions() {
    echo ""
    echo "=================================="
    echo "🎉 SETUP GITHUB TERMINÉ!"
    echo "=================================="
    echo ""
    echo "Prochaines étapes:"
    echo "1. Modifiez terraform.tfvars avec vos valeurs"
    echo "2. Testez le déploiement localement: ./deploy.sh"
    echo "3. Poussez vos modifications: git push"
    echo ""
    echo "Structure du projet:"
    echo "📁 terraform-azure-solo/"
    echo "├── 📄 main.tf                 # Infrastructure principale"
    echo "├── 📄 variables.tf            # Définition des variables"
    echo "├── 📄 outputs.tf              # Sorties importantes"
    echo "├── 📄 terraform.tfvars        # Valeurs des variables (à modifier)"
    echo "├── 📄 terraform.tfvars.example # Template de configuration"
    echo "├── 📄 README.md               # Documentation complète"
    echo "├── 📄 architecture.md         # Documentation technique"
    echo "├── 📄 deploy.sh               # Script de déploiement"
    echo "├── 📄 setup_github.sh         # Ce script"
    echo "├── 📄 .gitignore              # Fichiers à ignorer"
    echo "└── 📁 .github/"
    echo "    └── 📁 workflows/"
    echo "        └── 📄 terraform.yml   # CI/CD GitHub Actions"
    echo ""
    echo "Commandes utiles:"
    echo "- Déploiement: ./deploy.sh"
    echo "- Tests: ./deploy.sh --test"
    echo "- Destruction: ./deploy.sh --destroy"
    echo "- Plan seulement: ./deploy.sh --plan"
    echo ""
    echo "=================================="
}

# Fonction pour créer des captures d'écran automatiques
create_screenshots_readme() {
    print_message "Création du README pour les captures d'écran..."
    
    mkdir -p screenshots
    
    cat > screenshots/README.md << 'EOF'
# Captures d'écran du déploiement

## Ajoutez ici vos captures d'écran

### 1. Déploiement Terraform
- [ ] `terraform init` en cours
- [ ] `terraform plan` avec les ressources à créer
- [ ] `terraform apply` en cours
- [ ] `terraform apply` terminé avec succès

### 2. Azure Portal
- [ ] Resource Group créé
- [ ] Virtual Machine en cours d'exécution
- [ ] Network Security Group avec les règles
- [ ] IP publique assignée

### 3. Connexion SSH
- [ ] Connexion SSH réussie
- [ ] Commandes exécutées sur la VM

### 4. Serveur Web
- [ ] Page web accessible via navigateur
- [ ] Contenu personnalisé affiché

### 5. Monitoring
- [ ] Métriques de la VM dans Azure
- [ ] Logs de connexion

### 6. Nettoyage
- [ ] `terraform destroy` en cours
- [ ] Ressources supprimées

## Instructions pour les captures
1. Utilisez des outils comme `gnome-screenshot` ou `flameshot`
2. Nommez les fichiers de manière descriptive
3. Ajoutez des annotations si nécessaire
4. Respectez la vie privée (masquez les IPs si nécessaire)
EOF
    
    print_success "Dossier screenshots créé avec un README"
}

# Fonction principale
main() {
    echo "=================================="
    echo "🔧 SETUP REPOSITORY GITHUB"
    echo "=================================="
    echo "Étudiant: FIENI DANNIE INNOCENT JUNIOR"
    echo "Formation: Mastère 1 Cybersécurité & Cloud Computing"
    echo "École: IPSSI Nice"
    echo "=================================="
    echo ""
    
    # Vérifications préliminaires
    check_git
    
    # Initialisation Git
    init_git
    
    # Création des fichiers nécessaires
    create_tfvars_from_template
    create_github_actions
    create_screenshots_readme
    
    # Configuration Git
    add_files_to_git
    initial_commit
    
    # Création du repository GitHub
    create_github_repo
    
    # Instructions finales
    show_post_setup_instructions
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Ce script prépare le projet pour GitHub"
    echo ""
    echo "Options:"
    echo "  -h, --help     Afficher cette aide"
    echo "  --no-remote    Ne pas créer le repository GitHub distant"
    echo ""
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --no-remote)
        # Exécuter sans créer le repo distant
        check_git
        init_git
        create_tfvars_from_template
        create_github_actions
        create_screenshots_readme
        add_files_to_git
        initial_commit
        print_success "Repository local préparé. Créez manuellement le repository GitHub."
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