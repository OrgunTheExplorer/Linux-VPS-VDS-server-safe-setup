# Linux VPS / VDS Secure Server Setup

This repository provides a **step-by-step, minimal and safe bootstrap process**
for a freshly installed Linux VPS/VDS server.

⭐ Features

🔥 Bootstrap and secure a fresh Linux server automatically:

System update & upgrade

SSH setup with key-based authentication

SSH hardening

Firewall setup with UFW

Fail2Ban intrusion prevention

Optional backup scheduling via cron

Optional monitoring alerts

Simple port forwarding CLI (backport) for TCP/UDP services


1️⃣ First of all create your ssh key on the local machine 
```bash
ssh-keygen -t ed25519 -C "username@server-bootstrap"
```


you can check the public key 
```bash
cat ~/.ssh/id_ed25519.pub
```

2️⃣ login to the server with password 
```bash
ssh root@SERVER_IP
```


3️⃣ than install git for the bootstrap-kit 
```bash
apt install -y git
```


```bash
git clone https://github.com/OrgunTheExplorer/Linux-VPS-VDS-server-safe-setup.git
cd Linux-VPS-VDS-server-safe-setup/server-bootstrap-kit
```


4️⃣ Give EXEC permission to the scripts
```bash
chmod +x install.sh
```


5️⃣ And run the program
```bash
sudo ./install.sh
```

6️⃣Paste your ssh key in the local machine can be seen with step 1️⃣


7️⃣ Choose to enable or disable the ipv6



