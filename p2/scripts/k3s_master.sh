#!/bin/bash

echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server 
	--cluster-init 
	--write-kubeconfig-mode 644 
	--bind-address=192.168.42.110 
	--advertise-address=192.168.42.110 
	--node-ip=192.168.42.110" sh -

echo "Setting up aliase..."
echo "alias k='kubectl'" >> /home/vagrant/.bashrc

echo "Creating Deployments..."
k apply -f /vagrant/config/app-*-deployment.yaml
echo "Creating Services..."
k apply -f /vagrant/config/services.yaml
echo "Creating Ingress Route...."
k apply -f /vagrant/config/ingress.yaml