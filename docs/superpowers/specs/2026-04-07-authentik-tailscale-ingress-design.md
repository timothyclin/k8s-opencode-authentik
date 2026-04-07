# Authentik Tailscale Ingress Implementation Design

## Overview

Complete the Helm chart for Authentik by adding Tailscale ingress support, allowing secure deployment within a Tailscale tailnet.

## Requirements

- Deploy Authentik with automatic HTTPS via Tailscale operator
- Use existing values.yaml ingress configuration
- Support proxy tagging for access control
- Enable conditional ingress creation

## Architecture

The implementation adds a Kubernetes Ingress resource that leverages the Tailscale operator's ingress controller to expose the Authentik service securely within the tailnet.

## Components

### New Template: charts/authentik/templates/ingress.yaml

Creates a standard Kubernetes Ingress resource with:

- **ingressClassName:** tailscale (routes through Tailscale operator)
- **Annotations:** tailscale.com/tags for proxy device tagging
- **TLS Configuration:** Auto-provisioned Let's Encrypt certificates
- **Backend:** Authentik service HTTPS port (443)
- **Conditional Creation:** Only when ingress.enabled=true

### Modified Files

- Add charts/authentik/templates/ingress.yaml

## Data Flow

1. User accesses https://authentik.<tailnet>.ts.net
2. Tailscale operator proxy terminates TLS and forwards to Authentik service
3. Authentik handles authentication/authorization requests

## Error Handling

- Tailscale operator manages proxy health and cert renewal
- Invalid configurations fail at Helm template time
- Proxy failures logged in tailscale namespace

## Testing Strategy

- Helm template validation ensures YAML correctness
- Dry-run deployment checks ingress resource creation
- Integration tests verify HTTPS access via tailnet

## Security Considerations

- TLS 1.3 with auto-renewing certificates
- Proxy tagged with configurable tags for ACL control
- No external internet exposure (tailnet-only access)

## Implementation Notes

- Uses values.ingress.hostname for DNS name generation
- Backend service already exposes HTTPS on port 443
- Compatible with existing Tailscale operator installation