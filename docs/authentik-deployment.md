# Authentik Deployment

Install Authentik using the official Helm chart with external PostgreSQL.

## Add Authentik Helm Repository

```bash
# Add repository
helm repo add authentik https://charts.goauthentik.io
helm repo update

# List available versions
helm search repo authentik --versions | head -10
```

## Create Authentik Configuration

```yaml
# Save as authentik-values.yaml
authentik:
  # Secret key for encryption (generate a secure 32-char string)
  secret_key: "your-32-character-secret-key-here"
  
  # External PostgreSQL configuration
  postgresql:
    host: "authentik-db-rw.authentik.svc.cluster.local"
    port: 5432
    name: "app"
    user: "app"
    password: ""  # Set via secret

# Server configuration
server:
  replicas: 1
  ingress:
    enabled: true
    hosts:
      - authentik.yourdomain.com
    tls:
      - secretName: authentik-tls
        hosts:
          - authentik.yourdomain.com

# Worker configuration  
worker:
  replicas: 1

# Disable bundled PostgreSQL
postgresql:
  enabled: false
```

## Create Secrets

```bash
# Create PostgreSQL password secret
kubectl create secret generic authentik-postgres \
  --namespace authentik \
  --from-literal=password="$(kubectl get secret authentik-db-app -n authentik -o jsonpath='{.data.password}' | base64 -d)"

# Update values.yaml with password
sed -i 's/password: ""/password: "'$(kubectl get secret authentik-postgres -n authentik -o jsonpath='{.data.password}' | base64 -d)'"/' authentik-values.yaml
```

## Install Authentik

```bash
# Install with custom values
helm install authentik authentik/authentik \
  --namespace authentik \
  --values authentik-values.yaml \
  --version 2026.2.2 \
  --wait

# Verify deployment
kubectl get pods -n authentik
kubectl get ingress -n authentik
```

## Initial Configuration

1. **Access Authentik**: Navigate to `https://authentik.yourdomain.com`
2. **Create Admin User**: Follow the setup wizard
3. **Set Bootstrap Credentials**:
   - Username: `akadmin`
   - Password: Choose a secure password
   - Email: `admin@yourdomain.com`

## Verify Installation

```bash
# Check all pods are running
kubectl get pods -n authentik

# Check logs for errors
kubectl logs -n authentik deployment/authentik-server

# Test database connection
kubectl exec -n authentik deployment/authentik-worker -- ak test-db
```

## TLS Certificate Setup

If using cert-manager:

```yaml
# Add to authentik-values.yaml
server:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    tls:
      - secretName: authentik-tls
        hosts:
          - authentik.yourdomain.com
```

## Scaling

For production workloads:

```yaml
# Increase replicas
server:
  replicas: 3
worker:
  replicas: 2

# Enable autoscaling
server:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
```

## Backup Configuration

Authentik supports automated backups:

```yaml
# Configure backup destination
authentik:
  backup:
    enabled: true
    destination: "s3://your-backup-bucket/authentik"
    schedule: "0 2 * * *"  # Daily at 2 AM
```

## Troubleshooting

### Pod crashes
```bash
# Check logs
kubectl logs -n authentik deployment/authentik-server --previous

# Check events
kubectl get events -n authentik --sort-by=.metadata.creationTimestamp
```

### Database connection issues
```bash
# Test connection from pod
kubectl exec -n authentik deployment/authentik-worker -- python -c "
import psycopg2
conn = psycopg2.connect('host=authentik-db-rw.authentik.svc.cluster.local port=5432 dbname=app user=app password=YOUR_PASSWORD')
print('Connection successful')
"
```

### Ingress not accessible
```bash
# Check ingress status
kubectl describe ingress authentik-server -n authentik

# Verify DNS resolution
nslookup authentik.yourdomain.com
```