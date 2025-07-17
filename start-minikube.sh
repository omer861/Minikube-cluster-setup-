#!/bin/bash
set -eux

# Only run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root using sudo"
    exit 1
fi

# Update system and install dependencies
apt-get update -y
apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release sudo

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Install kubectl
KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install -o root -g root -m 0755 minikube /usr/local/bin/minikube
rm -f minikube

# Setup bash completion for kubectl
echo "source <(kubectl completion bash)" >> /home/ubuntu/.bashrc

ubuntu@ip-172-31-36-64:~$ cat start-minikube.sh 
#!/bin/bash
set -eux

# Ensure Minikube runs as non-root
export CHANGE_MINIKUBE_NONE_USER=true

# Prepare .kube and .minikube directories
mkdir -p $HOME/.kube
mkdir -p $HOME/.minikube
touch $HOME/.kube/config

# Start Minikube with Docker driver
minikube start --driver=docker

# Verify
kubectl get nodes
