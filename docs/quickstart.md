# Quick Start

Get Authentik running in your k8s-opencode cluster in 30 minutes.

## Prerequisites Check

```bash
# Verify Kubernetes access
kubectl cluster-info

# Check Helm version
helm version --short

# Verify ingress controller
kubectl get pods -n ingress-nginx
```

## 1. Deploy PostgreSQL (5 minutes)

```bash
# Create namespace
kubectl create namespace authentik

# Add CloudNativePG Helm repo
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update

# Install operator
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --wait

# Deploy PostgreSQL cluster
kubectl apply -f docs/examples/postgresql-cluster.yaml
```

## 2. Deploy Authentik (10 minutes)

```bash
# Add Authentik Helm repo
helm repo add authentik https://charts.goauthentik.io
helm repo update

# Create values file
cp docs/examples/values-official.yaml my-authentik-values.yaml

# Edit values (set your domain and secrets)
# - Change authentik.secret_key
# - Set postgresql.password from cluster secret
# - Configure ingress.hosts

# Deploy Authentik
helm install authentik authentik/authentik \
  --namespace authentik \
  --values my-authentik-values.yaml \
  --wait
```

## 3. Initial Setup (5 minutes)

```bash
# Get admin password
kubectl get secret -n authentik authentik-postgres \
  -o jsonpath='{.data.password}' | base64 -d

# Access Authentik
open https://authentik.yourdomain.com

# Complete setup wizard with:
# - Email: admin@yourdomain.com
# - Password: [from secret above]

# Note: If the values file doesn't include bootstrap settings, you may need to manually set up the admin user or update the values file with authentik.bootstrap_password.
```

## 4. Configure Authentik (10 minutes)

### Create OIDC Application

1. Go to **Applications** > **Applications** > **Create**
2. Name: `k8s-opencode`
3. Provider: Create new OIDC provider
4. Client ID: `k8s-opencode`
5. Redirect URIs: `https://k8s-opencode.yourdomain.com/oauth2/callback`

### Add Users and Groups

1. Go to **Directory** > **Users** > **Create**
2. Create admin and regular users
3. Go to **Directory** > **Groups** > **Create**
4. Create groups like `cluster-admins`, `developers`

## 5. Integrate with k8s-opencode (5 minutes)

```yaml
# Add to your k8s-opencode values.yaml
opencode:
  auth:
    oidc:
      enabled: true
      issuerUrl: "https://authentik.yourdomain.com/application/o/k8s-opencode/"
      clientId: "k8s-opencode"
      clientSecret: "your-client-secret-from-authentik"
      usernameClaim: "preferred_username"
      groupsClaim: "groups"
```

## Verification

```bash
# Check all pods running
kubectl get pods -n authentik

# Test login
curl -k https://authentik.yourdomain.com/-/health/live/

# Check database connection
kubectl exec -n authentik deployment/authentik-worker -- ak test-db
```

## Next Steps

- [Configure users and groups](authentik-setup.md)
- [Set up OIDC integration](oidc-integration.md)
- [Troubleshoot issues](troubleshooting.md)

## Cleanup (if needed)

```bash
# Uninstall Authentik
helm uninstall authentik -n authentik

# Remove PostgreSQL
kubectl delete cluster authentik-db -n authentik

# Remove namespace
kubectl delete namespace authentik
```