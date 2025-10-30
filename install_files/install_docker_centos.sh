#!/bin/bash

# Script d'installation de Docker et Docker Compose sur CentOS 9
# Utilise le plugin officiel docker-compose-plugin
# À exécuter avec sudo

# Vérifie si JENKINS_HOME est vide ou non définie
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "ERREUR : JENKINS_HOME non spécifié." >&2
  echo "Usage : $0 <chemin_vers_jenkins_home> \$USER" >&2
  exit 1
fi

JENKINS_HOME="$1"
user="$2"
set -e

echo "🔄 Mise à jour du système..."
dnf update -y

echo "📦 Installation des dépendances..."
dnf install -y dnf-plugins-core yum-utils

echo "📥 Ajout du dépôt officiel Docker..."
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "⚙️ Installation de Docker Engine, CLI, Containerd et Docker Compose Plugin..."
dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "🚀 Démarrage et activation du service Docker..."
systemctl start docker
systemctl enable docker

echo "✅ Vérification de Docker..."
docker --version

echo "✅ Vérification de Docker Compose..."
docker compose version

echo "ℹ️ Ajout de l'utilisateur actuel $user au groupe 'docker' (pour éviter sudo)..."
if ! groups "$user" | grep -q docker; then
    sudo usermod -aG docker "$user"
    echo "👉 Veuillez vous déconnecter et vous reconnecter pour appliquer les droits du groupe docker."
fi

echo "🎉 Docker et Docker Compose sont installés et prêts à l'emploi sur CentOS 9 !"

echo "⚙️ Créer le répertoire $JENKINS_HOME"
sudo mkdir -p $JENKINS_HOME
sudo chown -R 1000:1000 $JENKINS_HOME

echo "export JENKINS_HOME=$JENKINS_HOME to /home/$user/.bashrc"

echo "export JENKINS_HOME=$JENKINS_HOME" >> /home/$user/.bashrc

sudo -u $user -i source /home/$user/.bashrc

sudo -u $user -i export JENKINS_HOME=$JENKINS_HOME