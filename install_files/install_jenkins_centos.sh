#!/bin/bash

# Script d'installation de Jenkins sur CentOS 9

echo "🔄 Mise à jour du système..."
sudo dnf update -y

echo "☕ Installation de Java (OpenJDK 17)..."
sudo dnf install java-17-openjdk -y

echo "🔑 Importation de la clé du dépôt Jenkins..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "📦 Ajout du dépôt Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

echo "📥 Installation de Jenkins..."
sudo dnf install jenkins -y

echo "🚀 Démarrage du service Jenkins..."
sudo systemctl start jenkins

echo "🔁 Activation de Jenkins au démarrage..."
sudo systemctl enable jenkins

echo "✅ Vérification du statut de Jenkins..."
#sudo systemctl status jenkins

echo "🔐 Mot de passe initial d'administration Jenkins :"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "🌐 Jenkins est accessible sur http://localhost:8080"

# Ouverture des ports
# Vérifie que firewalld est actif
sudo systemctl status firewalld

# Si ce n’est pas le cas, démarre-le
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Ouvre le port 8080 en TCP
sudo firewall-cmd --permanent --add-port=8080/tcp

# Recharge les règles du pare-feu
sudo firewall-cmd --reload

# Vérifie que le port est bien ouvert
sudo firewall-cmd --list-ports