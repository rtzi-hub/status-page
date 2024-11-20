## This Pipeline:

**Stage 1**: Terraform Init + Plan + Apply 

**Stage 2**: Unitest - This unitest.py checks:
          - Verifying the whole python files without syntax error 

**Stage 3**: Build Docker Image

**Stage 4**: Push The New Image to DockerHub

**Stage 5**: Downloading ArgoCD inside the cluster - EKS
