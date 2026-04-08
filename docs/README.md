# Authentik for k8s-opencode Authentik Setup

Comprehensive guide for deploying Authentik Identity-Aware Proxy in k8s-opencode multi-user Kubernetes environments using the official Authentik Helm chart and CloudNativePG PostgreSQL operator.

## Quick Start

For the impatient:
1. [Check prerequisites](prerequisites.md)
2. [Deploy PostgreSQL operator](postgresql-setup.md)
3. [Install Authentik](authentik-deployment.md)
4. [Configure Authentik setup](authentik-setup.md)

## Documentation Structure

| Guide | Purpose | Time |
|-------|---------|------|
| [Prerequisites](prerequisites.md) | System requirements | 5 min |
| [PostgreSQL Setup](postgresql-setup.md) | CloudNativePG operator | 10 min |
| [Authentik Deployment](authentik-deployment.md) | Official Helm chart | 15 min |
| [Authentik Setup](authentik-setup.md) | Users, groups, policies | 20 min |
| [OIDC Integration](oidc-integration.md) | k8s-opencode setup | 15 min |
| [Troubleshooting](troubleshooting.md) | Common issues | As needed |

## Examples

Ready-to-use configurations in [examples/](examples/) directory.

## Support

- [Authentik Documentation](https://goauthentik.io/docs/)
- [CloudNativePG Docs](https://cloudnative-pg.io/)
- [k8s-opencode Issues](https://github.com/timothyclin/k8s-opencode/issues)