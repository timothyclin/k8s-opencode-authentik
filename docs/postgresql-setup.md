# PostgreSQL Setup with CloudNativePG

Deploy CloudNativePG operator and create Authentik database cluster.

## Why CloudNativePG?

CloudNativePG provides enterprise-grade PostgreSQL management with:
- Native Kubernetes integration
- Automated backups and high availability
- Multi-architecture support (AMD64/ARM64)
- Declarative configuration

## Install CloudNativePG Operator

```bash
# Add Helm repository
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update

# Install operator
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.21.0

# Verify installation
kubectl get pods -n cnpg-system
```

## Create Authentik Database Cluster

```yaml
# Save as postgresql-cluster.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: authentik-db
  namespace: authentik
spec:
  instances: 2
  imageName: ghcr.io/cloudnative-pg/postgresql:16
  storage:
    size: 10Gi
    storageClass: standard  # Adjust for your cluster
  postgresql:
    parameters:
      max_connections: "200"
      shared_buffers: "256MB"
  backup:
    barmanObjectStore:
      destinationPath: "s3://your-backup-bucket/authentik"
      endpointURL: "https://s3.amazonaws.com"  # Or your S3-compatible endpoint
      s3Credentials:
        accessKeyId:
          name: backup-secret
          key: access-key-id
        secretAccessKey:
          name: backup-secret
          key: secret-access-key
  monitoring:
    enablePodMonitor: true
---
apiVersion: v1
kind: Secret
metadata:
  name: backup-secret
  namespace: authentik
type: Opaque
data:
  access-key-id: <base64-encoded-access-key>
  secret-access-key: <base64-encoded-secret-key>
```

```bash
# Create namespace
kubectl create namespace authentik

# Apply cluster configuration
kubectl apply -f postgresql-cluster.yaml

# Wait for cluster to be ready
kubectl wait --for=condition=Ready cluster/authentik-db -n authentik --timeout=300s

# Get connection details
kubectl get secret authentik-db-app -n authentik -o jsonpath='{.data.password}' | base64 -d
```

## Connection Details for Authentik

After deployment, note these values for Authentik configuration:

- **Host**: `authentik-db-rw.authentik.svc.cluster.local`
- **Port**: `5432`
- **Database**: `app`
- **Username**: `app`
- **Password**: From secret `authentik-db-app`

## Monitoring

Enable monitoring if Prometheus is installed:

```bash
# Check if PodMonitor is created
kubectl get podmonitor -n authentik
```

## Troubleshooting

### Cluster not ready
```bash
# Check cluster status
kubectl describe cluster authentik-db -n authentik

# Check pod logs
kubectl logs -n authentik deployment/cnpg-controller-manager
```

### Storage issues
```bash
# Check PVC status
kubectl get pvc -n authentik

# Verify storage class
kubectl get storageclass
```