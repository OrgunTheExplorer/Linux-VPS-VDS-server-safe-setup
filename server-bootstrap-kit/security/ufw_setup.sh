#!/bin/bash

echo "Configuring UFW firewall..."

ufw default deny incoming
ufw default allow outgoing

ufw allow OpenSSH
ufw allow 80
ufw allow 443

ufw --force enable

echo "Firewall rules applied."
