# k8s-opencode-authentik

Standalone Helm chart for deploying Authentik Identity-Aware Proxy in Kubernetes clusters.

## Installation

```bash
helm install authentik ./charts/authentik \
  -n authentik --create-namespace \
  -f values.yaml
```

## Configuration

See `charts/authentik/values.yaml` for all configuration options.

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- Tailscale operator (for ingress)
