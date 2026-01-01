#!/bin/bash

USERNAME=${SUDO_USER:-root}
SSH_DIR="/home/$USERNAME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "Setting up SSH key authentication for user: $USERNAME"

mkdir -p $SSH_DIR
chmod 700 $SSH_DIR

if [ ! -f "$AUTHORIZED_KEYS" ]; then
  touch $AUTHORIZED_KEYS
  chmod 600 $AUTHORIZED_KEYS
fi

echo "Paste the PUBLIC SSH KEY for user $USERNAME:"
read -r SSH_KEY

echo "$SSH_KEY" >> $AUTHORIZED_KEYS

chown -R $USERNAME:$USERNAME $SSH_DIR

echo "SSH key successfully added."
echo "Password login is still ENABLED at this stage (safe)."
