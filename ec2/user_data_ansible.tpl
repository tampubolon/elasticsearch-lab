#!/bin/bash
apt update -y
apt upgrade -y

# Install Ansible
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible