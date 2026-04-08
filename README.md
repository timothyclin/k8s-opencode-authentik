# k8s-opencode-authentik

Comprehensive documentation and examples for deploying Authentik Identity-Aware Proxy in k8s-opencode multi-user Kubernetes environments using the official Authentik Helm chart and CloudNativePG PostgreSQL operator.

## 🚀 Quick Start

Get Authentik running in 30 minutes:

### For AI-Assisted Installation

Tell your LLM agent: 

```
Install Authentik for k8s-opencode by following the instructions here: https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/llm-install.md
```

1. **[Prerequisites Check](docs/prerequisites.md)**
2. **[Deploy PostgreSQL](docs/postgresql-setup.md)**
3. **[Install Authentik](docs/authentik-deployment.md)**
4. **[Configure Authentik](docs/authentik-setup.md)**
5. **[OIDC Integration](docs/oidc-integration.md)**

## 📚 Documentation

| Guide | Description | Time |
|-------|-------------|------|
| [Quick Start](docs/quickstart.md) | 30-minute deployment guide | 30 min |
| [Prerequisites](docs/prerequisites.md) | System requirements | 5 min |
| [PostgreSQL Setup](docs/postgresql-setup.md) | CloudNativePG operator | 10 min |
| [Authentik Deployment](docs/authentik-deployment.md) | Official Helm chart | 15 min |
| [Authentik Config](docs/authentik-setup.md) | Users, groups, policies | 20 min |
| [OIDC Integration](docs/oidc-integration.md) | k8s-opencode setup | 15 min |
| [Advanced Topics](docs/advanced-topics.md) | Monitoring, scaling, backups | 30 min |
| [Troubleshooting](docs/troubleshooting.md) | Common issues & solutions | As needed |
| [API Reference](docs/api-reference.md) | Authentik API usage | Reference |

## 🛠️ Examples

Ready-to-use configurations in [`docs/examples/`](docs/examples/):
- `values-official.yaml` - Complete Helm values
- `postgresql-cluster.yaml` - CloudNativePG cluster
- `oidc-client-config.yaml` - OIDC client examples

## 🎯 Use Cases

- **Multi-User Kubernetes**: Authentik as OIDC provider for k8s-opencode

(Showing lines 1-2000 of 4219. Use offset=2001 to continue.)