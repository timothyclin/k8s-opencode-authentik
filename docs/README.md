# Authentik Deployment Guide

## Prerequisites

- Kubernetes cluster with Tailscale operator installed
- Helm 3.0+
- Cluster admin access

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/timothyclin/k8s-opencode-authentik.git
cd k8s-opencode-authentik

# Install with default values
helm install authentik ./charts/authentik \
  -n authentik --create-namespace \
  -f charts/authentik/values.yaml
```

### Configuration

Edit `charts/authentik/values.yaml`:

- Set `domain` to your desired Tailscale hostname
- Change `secretKey` to a secure 32+ character string
- Configure `proxy.cookieDomain` for your tailnet

### Accessing Authentik

After installation, access the admin interface at:
`https://<domain>`

Default credentials:
- Username: admin
- Password: admin

## Troubleshooting

### Bootstrap Issues
If the admin user isn't created:
1. Check pod logs: `kubectl logs -n authentik deployment/authentik`
2. Verify `domain` and `secretKey` are set correctly
3. Ensure PostgreSQL and Redis are running

### Ingress Issues
If you can't access the UI:
1. Check Tailscale operator status
2. Verify domain configuration
3. Check ingress resource: `kubectl get ingress -n authentik`