#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"

echo "Hardening SSH configuration..."

cp $SSH_CONFIG ${SSH_CONFIG}.backup

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' $SSH_CONFIG
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSH_CONFIG

sed -i 's/^#\?UsePAM.*/UsePAM yes/' $SSH_CONFIG

echo "Root login and password authentication disabled."
