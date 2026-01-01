#!/bin/bash

echo "Configuring UFW firewall..."

# Ask user about IPv6
read -rp "Do you want to keep IPv6 enabled? (y/n): " IPV6_CHOICE

if [[ "$IPV6_CHOICE" == "n" || "$IPV6_CHOICE" == "N" ]]; then
    echo "Disabling IPv6 in UFW configuration..."
    sed -i 's/^IPV6=yes/IPV6=no/' /etc/default/ufw
else
    echo "Keeping IPv6 enabled."
fi

# Apply firewall defaults
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow OpenSSH

# Enable UFW
ufw --force enable

echo "Firewall rules applied."
