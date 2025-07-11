#!/bin/bash

# Script de configuration pour terraform-azure-solo
# Utilisation: ./setup.sh

echo "🚀 Configuration du projet Terraform Azure Solo"
echo "================================================"

# Vérifier si terraform.tfvars existe
if [ -f "terraform.tfvars" ]; then
    echo "⚠️  Le fichier terraform.tfvars existe déjà."
    read -p "Voulez-vous le remplacer ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Configuration annulée."
        exit 1
    fi
fi

# Copier le fichier d'exemple
if [ ! -f "terraform.tfvars.example" ]; then
    echo "❌ Fichier terraform.tfvars.example non trouvé!"
    exit 1
fi

cp terraform.tfvars.example terraform.tfvars
echo "✅ Fichier terraform.tfvars créé à partir du template"

# Obtenir l'IP publique
echo "🔍 Détection de votre adresse IP publique..."
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null)

if [ -z "$PUBLIC_IP" ]; then
    echo "⚠️  Impossible de détecter automatiquement votre IP publique"
    echo "Veuillez la configurer manuellement dans terraform.tfvars"
    echo "Utilisez: curl ifconfig.me"
else
    echo "📍 Votre IP publique: $PUBLIC_IP"
    
    # Remplacer l'IP dans le fichier
    sed -i "s/VOTRE_IP_PUBLIQUE\/32/${PUBLIC_IP}\/32/g" terraform.tfvars
    echo "✅ IP publique configurée automatiquement"
fi

# Demander le nom de l'utilisateur
echo ""
read -p "👤 Entrez votre nom pour les tags (ex: Jean Dupont): " USER_NAME
if [ ! -z "$USER_NAME" ]; then
    sed -i "s/VOTRE_NOM/$USER_NAME/g" terraform.tfvars
    echo "✅ Nom d'utilisateur configuré"
fi

echo ""
echo "🎉 Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Vérifiez le fichier terraform.tfvars"
echo "2. Connectez-vous à Azure: az login"
echo "3. Initialisez Terraform: terraform init"
echo "4. Planifiez le déploiement: terraform plan"
echo "5. Déployez l'infrastructure: terraform apply"
echo ""
echo "📖 Consultez le README.md pour plus d'informations"
