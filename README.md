# k8s-opencode-authentik

Standalone Helm chart for deploying Authentik Identity-Aware Proxy in Kubernetes clusters.

## Architecture Support

This chart supports deployment on both AMD64 and ARM64 architectures. The container images automatically resolve to the appropriate platform variant based on the target node architecture.

## Installation

### From source (development)

```bash
helm install authentik ./charts/authentik \
  -n authentik --create-namespace \
  -f values.yaml
```

### From GHCR (production)

```bash
helm install authentik oci://ghcr.io/timothyclin/k8s-opencode-authentik/chart/authentik \
  -n authentik --create-namespace \
  -f values.yaml
```

## Configuration

See `charts/authentik/values.yaml` for all configuration options.

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- Tailscale operator (for ingress)
