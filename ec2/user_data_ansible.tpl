#!/bin/bash
apt update -y
apt upgrade -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update -y
sudo apt install ansible -y