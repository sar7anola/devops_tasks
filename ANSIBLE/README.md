# Ansible + SSH Setup Guide  

This document explains the steps I followed to install and configure Ansible on Ubuntu, connect multiple machines (VMs) using SSH, and verify connectivity with `ansible -m ping`. It also includes steps to transfer files using FileZilla.  

---

## 1. Install Ansible on Ubuntu  
First update the system and install Ansible:  
```bash
sudo apt update
sudo apt install ansible -y
```

Check installation with:  
```bash
ansible --version
```  
## 2. Enable SSH Server on Target Machines  
On each VM:  
```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```  
---

## 3. Configure Ansible Inventory  
Create a file called `hosts.ini` in your home directory and add:  

```ini
[servers]  
sar7an ansible_host=172.20.100.188 ansible_user=sar7an  
ubuntu ansible_host=192.168.43.134 ansible_user=ubuntu  
```

---


```  

Check the VM’s IP address with:  
```bash
ip a
```  

---

## 4. Test SSH Connectivity  
From the control machine, connect to each VM:  
```bash
ssh sar7an@172.20.100.188
ssh ubuntu@192.168.43.134
```  

If prompted with a fingerprint message, type **yes**.  
If you see "Host key verification failed", remove the old entry with:  
```bash
ssh-keygen -R <IP>
```  

---

## 5. Authentication (Password or SSH Keys)  
You can log in using passwords, or set up SSH keys for easier access.  

Generate a new SSH key on the control node:  
```bash
ssh-keygen -t ed25519
```  

Then copy the key to each VM:  
```bash
ssh-copy-id sar7an@172.20.100.188
ssh-copy-id ubuntu@192.168.43.134
```  

---

## 6. Test Ansible Connectivity  
Run the ping module:  
```bash
ansible -i ~/hosts.ini servers -m ping
```  

Expected output:  
```
sar7an | SUCCESS => { "ping": "pong" }  
ubuntu | SUCCESS => { "ping": "pong" }  
```

---


```  

---
  

---

## ✅ Summary  
- Installed Ansible.  
- Created inventory file.  
- Enabled and configured SSH server on VMs.  
- Solved SSH key issues.  
- Successfully tested Ansible connection with `pong`.  

