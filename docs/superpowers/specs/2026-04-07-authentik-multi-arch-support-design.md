# Authentik Helm Chart Multi-Architecture Support Design

## Overview

Ensure the Authentik Helm chart supports deployment on both AMD64 and ARM64 architectures by using multi-architecture container images.

## Requirements

- All container images must be available for both linux/amd64 and linux/arm64 platforms
- Kubernetes should automatically pull the appropriate image variant based on node architecture
- No architecture-specific configuration required from users

## Architecture

Leverage Docker's multi-architecture manifests to provide seamless cross-platform support. Official images from Docker Hub and GitHub Container Registry are used, which typically include multi-arch support.

## Components

### Container Images

- **Authentik Server:** ghcr.io/goauthentik/server (supports amd64, arm64)
- **PostgreSQL:** postgres (official Docker image, multi-arch)
- **Redis:** redis (official Docker image, multi-arch)

### No Changes Required

The existing image configurations already support multi-architecture deployments through Docker's manifest lists.

## Data Flow

1. Helm deploys with image references
2. Kubernetes/containerd pulls appropriate architecture variant automatically
3. No user intervention needed

## Error Handling

- If a specific architecture variant is missing, deployment fails with image pull error
- Users can verify support with `docker manifest inspect <image>`

## Testing Strategy

- Deploy on amd64 nodes
- Deploy on arm64 nodes  
- Verify pods start successfully on both architectures

## Security Considerations

Multi-architecture images maintain the same security posture across platforms.

## Implementation Notes

- Official images are preferred for their regular security updates and multi-arch support
- No additional Helm templating needed for architecture selection