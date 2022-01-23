#!/bin/bash

echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent 
	--server https://192.168.42.110:6443 
	--token-file /vagrant/node-token
	--node-ip=192.168.42.111" sh -

echo "Setting up aliase..."
echo "alias k='kubectl'" >> /home/vagrant/.bashrc