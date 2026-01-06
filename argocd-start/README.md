# Argo CD Architecture in This Project
Argo CD acts as the GitOps controller for deploying and managing Kubernetes applications. It continuously monitors the repository, ensures that the Kubernetes cluster matches the desired state defined in the manifests, and automatically applies changes when the repository is updated. Here's how it is architected in this project:

## Key Components:
### 1. Git Repository:
- Contains all application manifests organized hierarchically.
- The repository root folder includes argocd-start/ with the "App of Apps" pattern.
### 2. App of Apps:
- The my-app-of-apps.yaml file is the parent Argo CD application.
- This parent application points to the repository path and manages multiple child applications (e.g., cert-manager-app.yaml, ingress-app.yaml, etc.).
### 3. Child Applications:
- Each child application represents a specific component like cert-manager, nginx-ingress, or Prometheus.
- These are synchronized and deployed as part of the parent application.
### 4. Sync Waves:
- Applications are deployed in a specific order using sync waves to ensure dependencies are set up before dependent applications.
### 5. Jenkins Pipeline:
- Automates building the Docker image, pushing it to DockerHub, and setting up Argo CD.
### 6. Kubernetes Cluster:
- The deployment target where Argo CD applies the desired configurations.

# Step-by-Step: Activating All Applications
## Step 1: Install and Access Argo CD
### 1. Install Argo CD in your Kubernetes cluster using the provided Jenkins pipeline script (cluster-install-argocd.sh) or manually:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### 2. Forward the Argo CD server port to access the UI locally:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
### 3. Open your browser and visit:
```bash
https://localhost:8080
```
### 4. Retrieve the Argo CD admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
### 5. Log in to Argo CD with the username admin and the retrieved password.

## Step 2: Add the Parent Application (App of Apps)
### 1. In the Argo CD UI, create a new application.
### 2. Set the following configurations:
- Application Name: my-app-of-apps
- Project: default
- Sync Policy: Automated (Prune and Self-Heal enabled)
- Repository URL: https://github.com/yair232/status-page
- Path: argocd-start
- Target Revision: HEAD
- Cluster URL: https://kubernetes.default.svc
- Namespace: argocd
### 3. Save the application. This parent application will now deploy all child applications.

## Step 3: Sync the Applications
### 1. In the Argo CD UI, select the my-app-of-apps application.
### 2. Click the Sync button to start the deployment process.
### 3. Argo CD will:
- Deploy each child application according to its sync wave.
- Monitor the deployment status of all resources.
### 4. Once all applications are synced and healthy, they will be visible in the Argo CD dashboard.

## Step 4: Add Required Credentials to Argo CD
To ensure Argo CD can access the GitHub repository and Helm charts for Prometheus and NGINX, you need to add the respective credentials.

### 1. Adding GitHub Repository Credentials
Log in to the Argo CD UI and navigate to Settings > Repositories.
Click Connect Repo using HTTPS.
Enter the following details:
- Repository URL: https://github.com/rtzi-hub/status-page
- Username: Your GitHub username.
- Password/Token: A GitHub personal access token with repo permissions.
Click Save.
Argo CD will now authenticate with the GitHub repository to sync the manifests.
### 2. Adding Helm Credentials for Prometheus
In the Argo CD UI, go to Settings > Repositories > Helm Repositories.
Click Add Helm Repository and enter the following:
- Name: prometheus-helm-repo
- Repository URL: https://prometheus-community.github.io/helm-charts
- Username: (If required, otherwise leave empty.)
- Password: (If required, otherwise leave empty.)
- Click Save.
Argo CD will now fetch Helm charts for Prometheus from this repository.
### 3. Adding Helm Credentials for NGINX
In the Argo CD UI, go to Settings > Repositories > Helm Repositories.
Click Add Helm Repository and enter the following:
- Name: nginx-helm-repo
- Repository URL: https://kubernetes.github.io/ingress-nginx
- Username: (If required, otherwise leave empty.)
- Password: (If required, otherwise leave empty.)
- Click Save.
Argo CD will now fetch Helm charts for NGINX Ingress from this repository.

