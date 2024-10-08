#!/bin/bash
# Update packages
sudo apt update && sudo apt upgrade -y

# mount ebs volume
sudo mkfs -t xfs /dev/xvdb
sudo mkdir /data
sudo mount /dev/xvdb  /data/

# Install nginx
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx