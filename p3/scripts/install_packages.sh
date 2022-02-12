#!/bin/bash

echo "Installing net-tools..."
yum install -y net-tools


echo "Installing Docker..."
curl -sfSL https://get.docker.com | bash
sudo systemctl start docker && sudo systemctl enable docker
systemctl start containerd.service && systemctl enable containerd.service
usermod -aG docker ${USER}


echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl
mkdir "/home/vagrant/.kube"
echo "export KUBECONFIG=\"/home/vagrant/.kube/config\"" >> /home/vagrant/.bashrc && source /home/vagrant/.bashrc


echo "Installing k3d..."
echo "export PATH=\"${PATH}:/usr/local/bin\"" >> /home/vagrant/.bashrc && source /home/vagrant/.bashrc
curl -sfSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash


echo "Installing ArgoCD..."
curl -sfSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd


echo "Setting up alias..."
echo "alias k='/usr/local/bin/kubectl'" >> /home/vagrant/.bashrc && source /home/vagrant/.bashrc


echo "Creating Cluser..."
k3d cluster create dev-cluster \
	--port 8080:80@loadbalancer \
	--port 8443:443@loadbalancer \
	--port 8888:8888@loadbalancer
k3d kubeconfig get dev-cluster >/home/vagrant/.kube/config


echo "Waiting for treafik jobs to finish"
kubectl -n kube-system wait --for=condition=complete --timeout=-1s jobs/helm-install-traefik-crd
kubectl -n kube-system wait --for=condition=complete --timeout=-1s jobs/helm-install-traefik


echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev


echo "Traefik tricks..."
sed -i "s/::1.*/#::1    localhost ip6-localhost ip6-loopback/g" /etc/hosts


echo "Creating ArgoCD..."
kubectl create -n argocd -f /vagrant/confs/argocd.yaml


echo "Creating ArgoCD Ingress Route..."
kubectl apply -n argocd -f /vagrant/confs/argocd-ingress.yaml


echo "Admin Panel Secret:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo


echo "Waiting for server to load"
kubectl rollout status deployment argocd-server -n argocd
kubectl rollout status deployment argocd-redis -n argocd
kubectl rollout status deployment argocd-repo-server -n argocd
kubectl rollout status deployment argocd-dex-server -n argocd


echo "Creating App..."
kubectl apply -f /vagrant/confs/app.yaml
