# Prerequisites

Ensure your environment meets these requirements before deploying Authentik.

## Kubernetes Cluster

- **Version**: Kubernetes 1.27+
- **Distributions**: Any CNCF-certified (k3s, microk8s, EKS, GKE, AKS supported)
- **Resources**: Minimum 2 CPU cores, 4GB RAM for Authentik + PostgreSQL
- **Storage**: Persistent volume support for PostgreSQL data

### Verification

```bash
# Check Kubernetes version
kubectl version --short

# Check cluster resources
kubectl get nodes
kubectl describe nodes | grep -A 5 "Capacity:"
```

## Helm

- **Version**: Helm 3.8+
- **Repositories**: Access to `https://charts.goauthentik.io` and `https://cloudnative-pg.github.io/charts`

### Installation

```bash
# Install Helm (if not present)
curl https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz -o helm.tar.gz
tar -zxvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Verify
helm version
```

## Networking

- **Ingress Controller**: Required for external access (nginx, traefik, etc.)
- **DNS**: Domain name for Authentik (e.g., `authentik.yourdomain.com`)
- **TLS**: Certificate management (cert-manager recommended)

## Security

- **RBAC**: Cluster-admin access for initial setup
- **Secrets Management**: Kubernetes secrets or external secret store
- **Network Policies**: Calico or similar for pod isolation

## Optional Components

- **cert-manager**: For automatic TLS certificates
- **External PostgreSQL**: If not using CloudNativePG operator
- **Monitoring**: Prometheus + Grafana for observability