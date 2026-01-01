#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "=============================="
echo " Linux Server Bootstrap Kit"
echo "=============================="


chmod +x security/*.sh


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


read -p "[STEP 8] Install backup system? (y/n): " INSTALL_BACKUP
if [[ "$INSTALL_BACKUP" == "y" ]]; then
    chmod +x backup/daily_backup.sh
    (crontab -l 2>/dev/null; echo "0 3 * * * $(pwd)/backup/daily_backup.sh >> /var/log/backup.log 2>&1") | crontab -
    echo "Backup system installed."
fi



read -p "[STEP 9] Install monitoring alerts? (y/n): " INSTALL_MONITOR
if [[ "$INSTALL_MONITOR" == "y" ]]; then
    chmod +x monitoring/*.sh
    (crontab -l 2>/dev/null; echo "*/5 * * * * $(pwd)/monitoring/resource_alert.sh") | crontab -
    echo "Monitoring alerts installed."
fi


echo "✅ Server bootstrap completed safely."
