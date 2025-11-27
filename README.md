# Webserver With RabbitMQ Project

Minimal lab setup for:
- Single-node Kubernetes cluster
- RabbitMQ via Bitnami Helm + local-path storage
- Node.js webserver that sends messages to RabbitMQ

---

## 1. Create Kubernetes Cluster (Single Node, kubeadm)

> This section installs containerd + kubeadm and creates a basic single-node cluster.

```bash
# Disable swap (required by Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable required kernel networking modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl for Kubernetes networking
cat <<EOC | sudo tee /etc/sysctl.d/kubernetes.conf >/dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOC
sudo sysctl --system

# Install containerd (container runtime)
sudo apt-get update
sudo apt-get install -y containerd

# Generate default containerd config and switch to systemd cgroups
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart + enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install kubeadm, kubelet, kubectl (v1.31 example)
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the control plane (replace 10.10.10.10 with your VM IP)
sudo kubeadm init \
  --apiserver-advertise-address=10.10.10.10 \
  --pod-network-cidr=192.168.0.0/16

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown "$(id -u):$(id -g)" $HOME/.kube/config

# Verify cluster is up
kubectl get nodes

# Install Calico CNI for pod networking
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
kubectl get pods -n kube-system

# Allow scheduling workloads on control-plane node (lab only)
kubectl taint nodes "$(hostname)" node-role.kubernetes.io/control-plane- || true
kubectl get nodes -o wide
```
## 2. Install RabbitMQ (Bitnami Helm + local-path)
This section configures dynamic storage and installs RabbitMQ with persistence.

Assumes you already created rabbitmq-values.yaml with:

global.security.allowInsecureImages: true

image.registry: docker.io

image.repository: bitnamilegacy/rabbitmq

image.tag: 4.1.3-debian-12-r1

auth.username: admin, auth.password: adminpassword, auth.erlangCookie: supersecretcookie

persistence.enabled: true, persistence.storageClass: "local-path", persistence.size: 8Gi

service.type: ClusterIP, volumePermissions.enabled: true

### Create namespace for RabbitMQ + webserver\
```bash
kubectl create namespace messaging || true
```
### Install local-path storage provisioner
```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml

### Make local-path the default StorageClass
kubectl patch storageclass local-path \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' || true
```
### Confirm StorageClass and provisioner pod
```bash
kubectl get sc
kubectl get pods -n local-path-storage
```
### Add Bitnami Helm repo (for RabbitMQ chart)
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update
```
### Clean existing RabbitMQ (if any) to avoid conflicts
```bash
helm uninstall rabbitmq -n messaging || true
kubectl delete pvc -n messaging --all || true
```
### Install RabbitMQ using your values file
```bash
helm install rabbitmq bitnami/rabbitmq \
  -n messaging \
  -f rabbitmq-values.yaml
```
### Check RabbitMQ pod, PVC and Service
```bash
kubectl get pods -n messaging
kubectl get pvc -n messaging
kubectl get svc -n messaging
```
### Expose RabbitMQ Management UI on localhost:15672
```bash
Login: user=admin, pass=adminpassword
kubectl port-forward svc/rabbitmq -n messaging 15672:15672
```

## 3. Deploy Webserver (Node.js + RabbitMQ)

This section deploys a simple HTTP webserver that publishes messages into RabbitMQ.

Assumptions:

You built and pushed an image for your Node.js webserver:
```bash
docker build -t <DOCKER_USER>/rabbitmq-webserver:v1 .

docker push <DOCKER_USER>/rabbitmq-webserver:v1
```
You have a webserver-deployment.yaml that:

Lives in namespace messaging

Uses image <DOCKER_USER>/rabbitmq-webserver:v1

Exposes containerPort: 8080

Has a Service called rabbitmq-webserver (ClusterIP, port 8080)

Sets env vars:
```bash
RABBITMQ_HOST=rabbitmq.messaging.svc.cluster.local

RABBITMQ_PORT=5672

RABBITMQ_USER from secret rabbitmq / key rabbitmq-username

RABBITMQ_PASS from secret rabbitmq / key rabbitmq-password

QUEUE_NAME=demo-queue
```
### Deploy the webserver (Deployment + Service)

```bash
kubectl apply -f webserver-deployment.yaml

# Verify that the webserver pod and service are running
kubectl get pods -n messaging
kubectl get svc -n messaging

# Port-forward webserver on localhost:8080
kubectl port-forward svc/rabbitmq-webserver -n messaging 8080:8080

# Test basic HTTP endpoint
curl http://localhost:8080/

# Send a message to RabbitMQ via webserver
curl "http://localhost:8080/send?msg=hi"
```
### 4. Check Messages in RabbitMQ

This section verifies that messages reached the demo-queue via the UI.

```bash
# If not already running, forward RabbitMQ UI again:
kubectl port-forward svc/rabbitmq -n messaging 15672:15672
```

Then open in browser:

```bash
http://localhost:15672
```
Login: admin / adminpassword

Go to Queues → demo-queue → verify messages.

```bash
::contentReference[oaicite:0]{index=0}
```
