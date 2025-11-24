#!/bin/bash

# Script d'installation de GitLab CE via Docker sur CentOS 9
# Dernière mise à jour : 2024

set -e  # Arrête en cas d'erreur

# === 1. Variables ===
GITLAB_HOST=${1:-"gitlab.example.com"}
GITLAB_HTTP_PORT=${2:-80}
GITLAB_HTTPS_PORT=${3:-443}
GITLAB_SSH_PORT=${4:-2222}  # Port SSH exposé (différent du 22 système)

GITLAB_DATA_DIR="/srv/gitlab"
GITLAB_CONFIG_DIR="$GITLAB_DATA_DIR/config"
GITLAB_LOGS_DIR="$GITLAB_DATA_DIR/logs"
GITLAB_DATA_SUBDIR="$GITLAB_DATA_DIR/data"

# === 2. Mise à jour du système ===
echo "🔄 Mise à jour du système..."
dnf update -y

# === 3. Installation de Docker ===
if ! command -v docker &> /dev/null; then
    echo "📦 Installation de Docker..."
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
else
    echo "✅ Docker est déjà installé."
fi

# === 4. Création des répertoires persistants ===
echo "📁 Création des dossiers de persistance..."
mkdir -p "$GITLAB_CONFIG_DIR" "$GITLAB_LOGS_DIR" "$GITLAB_DATA_SUBDIR"

# === 5. Configuration du pare-feu ===
echo "🔥 Configuration du pare-feu (firewalld)..."
firewall-cmd --permanent --add-port=$GITLAB_HTTP_PORT/tcp
firewall-cmd --permanent --add-port=$GITLAB_HTTPS_PORT/tcp
firewall-cmd --permanent --add-port=$GITLAB_SSH_PORT/tcp
firewall-cmd --reload

# === 6. Lancement du conteneur GitLab ===
echo "🚀 Lancement du conteneur GitLab CE..."

docker run --detach \
  --hostname "$GITLAB_HOST" \
  --publish "$GITLAB_HTTP_PORT":80 \
  --publish "$GITLAB_HTTPS_PORT":443 \
  --publish "$GITLAB_SSH_PORT":22 \
  --name gitlab \
  --restart always \
  --volume "$GITLAB_CONFIG_DIR":/etc/gitlab \
  --volume "$GITLAB_LOGS_DIR":/var/log/gitlab \
  --volume "$GITLAB_DATA_SUBDIR":/var/opt/gitlab \
  gitlab/gitlab-ce:latest

# === 7. Affichage des informations ===
echo ""
echo "✅ GitLab CE est en cours de démarrage dans un conteneur Docker !"
echo ""
echo "🌐 Accédez à GitLab via : http://$GITLAB_HOST:$GITLAB_HTTP_PORT"
echo "   ou via HTTPS (si configuré) : https://$GITLAB_HOST:$GITLAB_HTTPS_PORT"
echo "🔑 Le mot de passe root initial sera disponible dans quelques minutes dans :"
echo "   $GITLAB_CONFIG_DIR/initial_root_password"
echo ""
echo "⏳ Le premier démarrage peut prendre 5 à 10 minutes. Surveillez les logs avec :"
echo "   docker logs -f gitlab"
echo ""
echo "💡 Conseil : modifiez le mot de passe root dès la première connexion."
echo ""

# Optionnel : attendre que le fichier de mot de passe soit créé (utile en mode non-interactif)
echo "⏳ Attente de la génération du mot de passe initial (jusqu'à 5 min)..."
for i in {1..60}; do
    if [ -f "$GITLAB_CONFIG_DIR/initial_root_password" ]; then
        echo ""
        echo "🔑 Mot de passe root initial détecté :"
        grep 'Password:' "$GITLAB_CONFIG_DIR/initial_root_password"
        break
    fi
    sleep 5
done