#!/bin/bash
echo martinus-1
apt update -y
echo martinus-2
apt upgrade -y
echo martinus-3
apt-get install -y software-properties-common
echo martinus-4
apt-add-repository --yes --update ppa:ansible/ansible
echo martinus-5
sudo apt-get install -y ansible
echo martinus-6
