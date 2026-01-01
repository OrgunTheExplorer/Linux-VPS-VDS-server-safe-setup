# Linux VPS / VDS Secure Server Setup

This repository provides a **step-by-step, minimal and safe bootstrap process**
for a freshly installed Linux VPS/VDS server.

The goal is:
- Secure SSH access with **key-based authentication**
- Disable insecure login methods
- Configure **UFW** and **Fail2Ban**
- Apply all changes in a controlled and testable order




1️⃣ First of all create your ssh key on the local machine 
```bash
ssh-keygen -t ed25519 -C "username@server-bootstrap"
```


you can check the public key 
```bash
~/.ssh/id_ed25519.pub
```

2️⃣ login to the server with password 
```bash
ssh root@SERVER_IP
```


3️⃣ autorize your local ssh key in the server
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```
and at the text editor paste your ssh key



than lock your ssh key other users have no access to it. Suitable for private text files.
```bash
chmod 600 ~/.ssh/authorized_keys
```

4️⃣ check If your ssh key is working from the local machine If you cannot login to the computer something is wrong and do not proceed ⚠️
```bash
ssh root@SERVER_IP
```



5️⃣ than install git for the bootstrap-kit 
```bash
apt install -y git
```


```bash
git clone https://github.com/OrgunTheExplorer/Linux-VPS-VDS-server-safe-setup.git
cd Linux-VPS-VDS-server-safe-setup/server-bootstrap-kit
```

6️⃣ Give EXEC permission to the scripts
```bash
chmod +x install.sh
chmod +x security/*.sh
```
7️⃣ And run the program
```bash
./install.sh
```

