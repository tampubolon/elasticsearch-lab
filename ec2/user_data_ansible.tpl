#!/bin/bash
echo martinus-1
apt-get install -y software-properties-common
echo martinus-2
sudo apt-add-repository --yes --update ppa:ansible/ansible
echo martinus-3
sudo apt update -y
echo martinus-4
sudo apt upgrade -y
echo martinus-5
sudo kill 16430
echo martinus-6
sudo apt install -y ansible
echo martinus-7