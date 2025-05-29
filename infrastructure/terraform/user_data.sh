#!/bin/bash

# Minimal user data - just ensure Ansible can connect and work

# Update package list
apt-get update -y

# Install Python (required for Ansible)
apt-get install -y python3 python3-pip

# Ensure SSH is ready
systemctl enable ssh
systemctl start ssh

# Log completion
echo "Minimal user data script completed at $(date)" >> /var/log/user-data.log 