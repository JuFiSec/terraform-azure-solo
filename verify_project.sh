#!/bin/bash

# Script de vérification complète du projet TP Terraform Azure
# Auteur: FIENI DANNIE INNOCENT JUNIOR
# Formation: Mastère 1 Cybersécurité & Cloud Computing - IPSSI Nice

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Variables globales
SCORE=0
MAX_SCORE=20
ERRORS=()
WARNINGS=()

# Fonction pour ajouter des points
add_points() {
    local points=$1
    local description=$2
    SCORE=$((SCORE + points))
    print_success "$description (+$points pts)"
}

# Fonction pour ajouter une erreur
add_error() {
    local description=$1
    ERRORS+=("$description")
    print_error "$description"
}

# Fonction pour ajouter un warning
add_warning() {
    local description=$1
    WARNINGS+=("$description")
    print_warning "$description"
}

# Vérification de la structure du projet
check_project_structure() {
    print_message "Vérification de la structure du projet..."
    
    local required_files=(
        "main.tf"
        "variables.tf"
        "outputs.tf"
        "terraform.tfvars"
        "README.md"
        "architecture.md"
        ".gitignore"
    )
    
    local optional_files=(
        "deploy.sh"
        "terraform.tfvars.example"
        ".github/workflows/terraform.yml"
    )
    
    local structure_score=0
    
    # Vérification des fichiers obligatoires
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            structure_score=$((structure_score + 1))
            print_success "Fichier $file présent"
        else
            add_error "Fichier obligatoire manquant: $file"
        fi
    done
    
    # Vérification des fichiers optionnels (bonus)
    for file in "${optional_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "Fichier bonus présent: $file"
        fi
    done
    
    # Vérification des dossiers
    if [ -d "screenshots" ]; then
        print_success "Dossier screenshots présent"
    else
        add_warning "Dossier screenshots manquant"
    fi
    
    if [ -d ".git" ]; then
        print_success "Repository Git initialisé"
    else
        add_warning "Repository Git non initialisé"
    fi
    
    # Attribution des points pour la structure
    if [ $structure_score -eq 7 ]; then
        add_points 2 "Structure de projet complète"
    elif [ $structure_score -ge 5 ]; then
        add_points 1 "Structure de projet partielle"
    else
        add_error "Structure de projet insuffisante"
    fi
}

# Vérification de la syntaxe Terraform
check_terraform_syntax() {
    print_message "Vérification de la syntaxe Terraform..."
    
    # Vérification de l'installation de Terraform
    if ! command -v terraform &> /dev/null; then
        add_error "Terraform n'est pas installé"
        return
    fi
    
    # Vérification du formatage
    if terraform fmt -check &> /dev/null; then
        add_points 1 "Code Terraform correctement formaté"
    else
        add_warning "Code Terraform mal formaté (utilisez: terraform fmt)"
    fi
    
    # Vérification de la syntaxe
    if terraform validate &> /dev/null; then
        add_points 2 "Syntaxe Terraform valide"
    else
        add_error "Erreurs de syntaxe Terraform détectées"
        terraform validate
    fi
}

# Vérification du contenu des fichiers
check_file_content() {
    print_message "Vérification du contenu des fichiers..."
    
    # Vérification de main.tf
    if [ -f "main.tf" ]; then
        local main_content=$(cat main.tf)
        
        # Vérification des ressources obligatoires
        local required_resources=(
            "azurerm_resource_group"
            "azurerm_virtual_network"
            "azurerm_subnet"
            "azurerm_public_ip"
            "azurerm_network_security_group"
            "azurerm_network_interface"
            "azurerm_linux_virtual_machine"
        )
        
        local resource_count=0
        for resource in "${required_resources[@]}"; do
            if echo "$main_content" | grep -q "$resource"; then
                resource_count=$((resource_count + 1))
            else
                add_error "Ressource manquante dans main.tf: $resource"
            fi
        done
        
        if [ $resource_count -eq 7 ]; then
            add_points 3 "Toutes les ressources Azure présentes"
        elif [ $resource_count -ge 5 ]; then
            add_points 2 "Ressources Azure principales présentes"
        else
            add_error "Ressources Azure insuffisantes"
        fi
        
        # Vérification des bonnes pratiques
        if echo "$main_content" | grep -q "tags.*=.*var.common_tags"; then
            add_points 1 "Tags correctement utilisés"
        else
            add_warning "Tags non utilisés ou mal configurés"
        fi
    fi
    
    # Vérification de variables.tf
    if [ -f "variables.tf" ]; then
        local var_content=$(cat variables.tf)
        local required_vars=("location" "environment" "vm_size" "admin_username")
        local var_count=0
        
        for var in "${required_vars[@]}"; do
            if echo "$var_content" | grep -q "variable.*\"$var\""; then
                var_count=$((var_count + 1))
            fi
        done
        
        if [ $var_count -eq 4 ]; then
            add_points 1 "Variables obligatoires définies"
        else
            add_warning "Variables manquantes dans variables.tf"
        fi
    fi
    
    # Vérification de outputs.tf
    if [ -f "outputs.tf" ]; then
        local output_content=$(cat outputs.tf)
        local required_outputs=("public_ip_address" "ssh_connection_command")
        local output_count=0
        
        for output in "${required_outputs[@]}"; do
            if echo "$output_content" | grep -q "output.*\"$output\""; then
                output_count=$((output_count + 1))
            fi
        done
        
        if [ $output_count -eq 2 ]; then
            add_points 1 "Outputs obligatoires définis"
        else
            add_warning "Outputs manquants dans outputs.tf"
        fi
    fi
}

# Vérification de la configuration
check_configuration() {
    print_message "Vérification de la configuration..."
    
    # Vérification de terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        local tfvars_content=$(cat terraform.tfvars)
        
        # Vérification de l'IP de sécurité
        if echo "$tfvars_content" | grep -q 'my_ip_address.*=.*"0.0.0.0/0"'; then
            add_error "IP de sécurité non configurée (0.0.0.0/0 n'est pas sécurisé)"
        elif echo "$tfvars_content" | grep -q 'my_ip_address.*=.*"/32"'; then
            add_points 1 "IP de sécurité correctement configurée"
        else
            add_warning "Configuration IP de sécurité à vérifier"
        fi
        
        # Vérification du nom d'étudiant
        if echo "$tfvars_content" | grep -q "FIENI DANNIE INNOCENT JUNIOR"; then
            add_points 1 "Informations d'étudiant correctes"
        else
            add_warning "Informations d'étudiant à vérifier"
        fi
    else
        add_error "Fichier terraform.tfvars manquant"
    fi
}

# Vérification de la documentation
check_documentation() {
    print_message "Vérification de la documentation..."
    
    # Vérification du README.md
    if [ -f "README.md" ]; then
        local readme_content=$(cat README.md)
        local readme_score=0
        
        # Vérification des sections importantes
        if echo "$readme_content" | grep -qi "prérequis"; then
            readme_score=$((readme_score + 1))
        fi
        
        if echo "$readme_content" | grep -qi "installation"; then
            readme_score=$((readme_score + 1))
        fi
        
        if echo "$readme_content" | grep -qi "déploiement"; then
            readme_score=$((readme_score + 1))
        fi
        
        if echo "$readme_content" | grep -qi "nettoyage\|destroy"; then
            readme_score=$((readme_score + 1))
        fi
        
        if echo "$readme_content" | grep -q "FIENI DANNIE INNOCENT JUNIOR"; then
            readme_score=$((readme_score + 1))
        fi
        
        if [ $readme_score -ge 4 ]; then
            add_points 2 "README.md complet et informatif"
        elif [ $readme_score -ge 2 ]; then
            add_points 1 "README.md basique"
        else
            add_warning "README.md insuffisant"
        fi
    else
        add_error "README.md manquant"
    fi
    
    # Vérification de architecture.md
    if [ -f "architecture.md" ]; then
        local arch_content=$(cat architecture.md)
        if echo "$arch_content" | grep -qi "architecture\|composant\|sécurité"; then
            add_points 1 "Documentation technique présente"
        fi
    else
        add_warning "Documentation technique (architecture.md) manquante"
    fi
}

# Vérification de la sécurité
check_security() {
    print_message "Vérification de la sécurité..."
    
    # Vérification du .gitignore
    if [ -f ".gitignore" ]; then
        local gitignore_content=$(cat .gitignore)
        local security_score=0
        
        if echo "$gitignore_content" | grep -q "\.tfstate"; then
            security_score=$((security_score + 1))
        fi
        
        if echo "$gitignore_content" | grep -q "\.pem\|ssh_key"; then
            security_score=$((security_score + 1))
        fi
        
        if echo "$gitignore_content" | grep -q "\.tfvars"; then
            security_score=$((security_score + 1))
        fi
        
        if [ $security_score -eq 3 ]; then
            add_points 2 "Fichiers sensibles correctement ignorés"
        elif [ $security_score -ge 1 ]; then
            add_points 1 "Sécurité partielle du .gitignore"
        else
            add_warning ".gitignore insuffisant pour la sécurité"
        fi
    else
        add_error ".gitignore manquant (risque de sécurité)"
    fi
    
    # Vérification qu'aucun fichier sensible n'est tracké
    if [ -d ".git" ]; then
        if git ls-files | grep -q "\.pem$\|ssh_key\|\.tfstate"; then
            add_error "Fichiers sensibles trackés dans Git!"
        else
            add_points 1 "Aucun fichier sensible tracké"
        fi
    fi
}

# Vérification des captures d'écran
check_screenshots() {
    print_message "Vérification des captures d'écran..."
    
    if [ -d "screenshots" ]; then
        local screenshot_count=$(find screenshots -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | wc -l)
        
        if [ $screenshot_count -ge 15 ]; then
            add_points 2 "Captures d'écran nombreuses ($screenshot_count fichiers)"
        elif [ $screenshot_count -ge 10 ]; then
            add_points 1 "Captures d'écran suffisantes ($screenshot_count fichiers)"
        elif [ $screenshot_count -ge 5 ]; then
            add_warning "Captures d'écran insuffisantes ($screenshot_count fichiers)"
        else
            add_warning "Très peu de captures d'écran ($screenshot_count fichiers)"
        fi
        
        # Vérification du README des captures
        if [ -f "screenshots/README.md" ]; then
            print_success "Documentation des captures présente"
        else
            add_warning "Documentation des captures manquante"
        fi
    else
        add_warning "Dossier screenshots manquant"
    fi
}

# Test de connectivité Azure (si possible)
check_azure_connection() {
    print_message "Vérification de la connectivité Azure..."
    
    if command -v az &> /dev/null; then
        if az account show &> /dev/null; then
            add_points 1 "Connexion Azure active"
            
            # Vérification de l'état Terraform si possible
            if [ -f "terraform.tfstate" ]; then
                print_success "État Terraform présent (infrastructure possiblement déployée)"
            fi
        else
            add_warning "Non connecté à Azure (az login requis)"
        fi
    else
        add_warning "Azure CLI non installé"
    fi
}

# Vérification des bonnes pratiques
check_best_practices() {
    print_message "Vérification des bonnes pratiques..."
    
    # Vérification de la structure des commits Git
    if [ -d ".git" ]; then
        local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
        if [ "$commit_count" -gt 0 ]; then
            add_points 1 "Repository Git avec commits"
            
            # Vérification du message de commit initial
            local first_commit=$(git log --oneline | tail -1)
            if echo "$first_commit" | grep -qi "initial\|TP\|terraform"; then
                print_success "Message de commit descriptif"
            fi
        fi
    fi
    
    # Vérification de la présence de scripts utiles
    if [ -f "deploy.sh" ] && [ -x "deploy.sh" ]; then
        add_points 1 "Script de déploiement présent et exécutable"
    fi
    
    # Vérification de la présence de GitHub Actions
    if [ -f ".github/workflows/terraform.yml" ]; then
        print_success "CI/CD GitHub Actions configuré (bonus)"
    fi
}

# Fonction pour afficher le rapport final
show_final_report() {
    echo ""
    echo "========================================"
    echo "📊 RAPPORT DE VÉRIFICATION FINAL"
    echo "========================================"
    echo "Étudiant: FIENI DANNIE INNOCENT JUNIOR"
    echo "Projet: TP Terraform Azure Infrastructure"
    echo "========================================"
    echo ""
    
    # Calcul du pourcentage
    local percentage=$((SCORE * 100 / MAX_SCORE))
    
    # Affichage du score avec couleur
    if [ $SCORE -ge 18 ]; then
        print_success "SCORE FINAL: $SCORE/$MAX_SCORE ($percentage%) - EXCELLENT 🏆"
    elif [ $SCORE -ge 15 ]; then
        print_success "SCORE FINAL: $SCORE/$MAX_SCORE ($percentage%) - TRÈS BIEN 🥉"
    elif [ $SCORE -ge 12 ]; then
        print_message "SCORE FINAL: $SCORE/$MAX_SCORE ($percentage%) - BIEN 👍"
    elif [ $SCORE -ge 10 ]; then
        print_warning "SCORE FINAL: $SCORE/$MAX_SCORE ($percentage%) - SATISFAISANT ⚠️"
    else
        print_error "SCORE FINAL: $SCORE/$MAX_SCORE ($percentage%) - INSUFFISANT ❌"
    fi
    
    echo ""
    
    # Détail par catégorie
    echo "Répartition par critères:"
    echo "• Structure du code: /5"
    echo "• Fonctionnalité: /5"
    echo "• Bonnes pratiques: /4"
    echo "• Documentation: /3"
    echo "• Sécurité: /3"
    echo ""
    
    # Affichage des erreurs
    if [ ${#ERRORS[@]} -gt 0 ]; then
        echo "❌ ERREURS À CORRIGER:"
        for error in "${ERRORS[@]}"; do
            echo "  - $error"
        done
        echo ""
    fi
    
    # Affichage des warnings
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo "⚠️  AMÉLIORATIONS SUGGÉRÉES:"
        for warning in "${WARNINGS[@]}"; do
            echo "  - $warning"
        done
        echo ""
    fi
    
    # Recommandations finales
    echo "📋 RECOMMANDATIONS:"
    if [ $SCORE -lt 15 ]; then
        echo "  - Corrigez les erreurs listées ci-dessus"
        echo "  - Complétez la documentation manquante"
        echo "  - Ajoutez plus de captures d'écran"
    fi
    echo "  - Testez le déploiement complet avec ./deploy.sh"
    echo "  - Vérifiez que l'infrastructure fonctionne"
    echo "  - Assurez-vous que les captures sont complètes"
    echo "  - Poussez tout sur GitHub avant la deadline"
    echo ""
    
    # Prochaines étapes
    echo "🚀 PROCHAINES ÉTAPES:"
    echo "  1. Corrigez les points mentionnés"
    echo "  2. Testez le déploiement: ./deploy.sh"
    echo "  3. Prenez les captures manquantes"
    echo "  4. Poussez sur GitHub: git push"
    echo "  5. Vérifiez que votre prof peut voir le repo"
    echo ""
    echo "========================================"
    
    # Code de retour basé sur le score
    if [ $SCORE -ge 12 ]; then
        return 0  # Succès
    else
        return 1  # Échec
    fi
}

# Fonction principale
main() {
    echo "========================================"
    echo "🔍 VÉRIFICATION PROJET TP TERRAFORM"
    echo "========================================"
    echo "Étudiant: FIENI DANNIE INNOCENT JUNIOR"
    echo "Formation: Mastère 1 Cybersécurité & Cloud Computing"
    echo "École: IPSSI Nice"
    echo "========================================"
    echo ""
    
    # Vérification que nous sommes dans le bon dossier
    if [ ! -f "main.tf" ] && [ ! -f "terraform-azure-solo/main.tf" ]; then
        print_error "Aucun projet Terraform détecté dans ce dossier"
        echo "Placez-vous dans le dossier terraform-azure-solo/"
        exit 1
    fi
    
    # Si nous sommes dans le dossier parent, aller dans le sous-dossier
    if [ -d "terraform-azure-solo" ] && [ ! -f "main.tf" ]; then
        cd terraform-azure-solo
        print_message "Déplacement vers terraform-azure-solo/"
    fi
    
    # Exécution de toutes les vérifications
    check_project_structure
    check_terraform_syntax
    check_file_content
    check_configuration
    check_documentation
    check_security
    check_screenshots
    check_azure_connection
    check_best_practices
    
    # Rapport final
    show_final_report
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Script de vérification complète du projet TP Terraform Azure"
    echo ""
    echo "Options:"
    echo "  -h, --help       Afficher cette aide"
    echo "  -q, --quick      Vérification rapide (sans Azure)"
    echo "  -v, --verbose    Mode verbeux"
    echo ""
    echo "Le script vérifie:"
    echo "  • Structure du projet"
    echo "  • Syntaxe Terraform"
    echo "  • Contenu des fichiers"
    echo "  • Configuration"
    echo "  • Documentation"
    echo "  • Sécurité"
    echo "  • Captures d'écran"
    echo "  • Bonnes pratiques"
    echo ""
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -q|--quick)
        # Mode rapide (skip Azure check)
        main() {
            check_project_structure
            check_terraform_syntax
            check_file_content
            check_configuration
            check_documentation
            check_security
            check_screenshots
            check_best_practices
            show_final_report
        }
        main
        ;;
    -v|--verbose)
        set -x
        main
        ;;
    "")
        main
        ;;
    *)
        echo "Option inconnue: $1"
        show_help
        exit 1
        ;;
esac