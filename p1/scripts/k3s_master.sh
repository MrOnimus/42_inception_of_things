#!/bin/bash

echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server 
	--cluster-init 
	--write-kubeconfig-mode 644 
	--bind-address=192.168.42.110 
	--advertise-address=192.168.42.110 
	--node-ip=192.168.42.110" sh -

echo "Copy node-token file for agent node..."
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token

echo "Setting up aliase..."
echo "alias k='kubectl'" >> /home/vagrant/.bashrc