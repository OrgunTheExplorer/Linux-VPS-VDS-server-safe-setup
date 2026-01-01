#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "=============================="
echo " Linux Server Bootstrap Kit"
echo "=============================="

echo "[STEP 1] Updating system packages..."
apt update && apt upgrade -y

echo "[STEP 2] Installing OpenSSH server..."
apt install -y openssh-server
systemctl enable ssh
systemctl start ssh

echo "[STEP 3] Setting up SSH key authentication..."
bash security/ssh_key_setup.sh

echo "[STEP 4] Testing SSH service status..."
systemctl status ssh --no-pager

echo "[STEP 5] Applying SSH hardening rules..."
bash security/ssh_hardening.sh

echo "[STEP 6] Installing firewall and intrusion prevention..."
apt install -y ufw fail2ban

bash security/ufw_setup.sh
bash security/fail2ban_setup.sh

echo "[STEP 7] Restarting security services..."
systemctl restart ssh
systemctl restart ufw
systemctl restart fail2ban

echo "✅ Server bootstrap completed safely."
