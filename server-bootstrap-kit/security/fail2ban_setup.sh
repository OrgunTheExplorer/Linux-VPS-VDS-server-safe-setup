#!/bin/bash

echo "Configuring Fail2Ban..."

cat <<EOF >/etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
maxretry = 5
bantime = 3600
findtime = 600
EOF

echo "Fail2Ban configuration written."

