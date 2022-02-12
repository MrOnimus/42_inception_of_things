echo "Installing Helm..."
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


echo "Creating namespace for gitlab..."
sudo kubectl create namespace gitlab


echo "Adding GitLab helm repo..."
sudo helm repo add gitlab https://charts.gitlab.io/ && sudo helm repo update


echo "Installing GitLab..."
sudo helm upgrade --install gitlab gitlab/gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=10.11.1.253.nip.io \
  --set global.hosts.externalIP=10.11.1.253 \
  --set global.edition=ce \
  --timeout 1000s \
  -n gitlab


echo "Waiting the deployments to get ready..."
sudo kubectl wait --for=condition=available deployments --all -n gitlab


echo "To access the UI use this command:"
echo "sudo kubectl port-forward svc/gitlab-webservice-default --address 10.11.1.253 -n gitlab 8082:8080 2>&1 >/dev/null &"


echo "To get auto-generated GitLab password for root user use this command:"
echo "kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode ; echo"
