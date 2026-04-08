# Authentik Documentation for k8s-opencode Multi-User Installation Design

## Overview

Transform this repository into comprehensive, AI-friendly documentation showing how to deploy and configure Authentik Identity-Aware Proxy for k8s-opencode multi-user Kubernetes environments. Focus on production-ready setups using the official Authentik Helm chart with CloudNativePG PostgreSQL operator, providing both human-readable step-by-step guides and AI-optimized configuration examples.

## Requirements

- **Official Authentik Chart**: Use authentik/authentik Helm chart from charts.goauthentik.io
- **PostgreSQL Operator**: CloudNativePG for multi-platform support (AMD64/ARM64, various K8s distros)
- **Multi-User Focus**: Tenant isolation, user management, OIDC integration with k8s-opencode
- **AI-Friendly Format**: Structured examples, copy-paste commands, troubleshooting decision trees
- **Reference Style**: Follow documentation structure from https://github.com/timothyclin/k8s-opencode

## Architecture

The documentation guides users through:
1. **Infrastructure Setup**: CloudNativePG operator deployment
2. **Authentik Deployment**: Official Helm chart with production PostgreSQL
3. **Multi-User Configuration**: Tenants, policies, user sources
4. **k8s-opencode Integration**: OIDC provider setup, application protection

## Components

### docs/ Directory Structure

```
docs/
├── README.md              # Main documentation hub
├── quickstart.md          # 10-minute getting started
├── prerequisites.md       # System requirements, K8s setup
├── postgresql-setup.md    # CloudNativePG operator deployment
├── authentik-deployment.md # Official Helm chart installation
├── multi-user-config.md   # Tenant/user management
├── oidc-integration.md    # k8s-opencode OIDC setup
├── advanced-topics.md     # Monitoring, scaling, backups
├── troubleshooting.md     # Common issues with AI decision trees
├── examples/              # AI-optimized configuration examples
│   ├── values-official.yaml
│   ├── postgresql-cluster.yaml
│   └── oidc-client-config.yaml
└── api-reference.md       # Authentik API usage
```

### Key Documentation Features

- **Human Step-by-Step Guides**: Numbered procedures with screenshots/mockups
- **AI-Optimized Examples**: YAML configs with inline comments, copy-paste ready
- **Decision Trees**: Troubleshooting guides with "if-then" logic for AI parsing
- **Cross-References**: Links between sections, related configurations
- **Version Pinning**: Specific chart versions, operator releases

## Data Flow

1. **Prerequisites Check** → User verifies K8s cluster meets requirements
2. **PostgreSQL Setup** → Deploy CloudNativePG operator and cluster
3. **Authentik Install** → Helm install with external PostgreSQL connection
4. **Initial Config** → Bootstrap admin, set secrets
5. **Multi-User Setup** → Create tenants, users, policies
6. **OIDC Integration** → Configure k8s-opencode as OIDC client
7. **Application Protection** → Deploy outposts, protect services

## Implementation Notes

- **Chart Version**: Pin to stable official releases (currently 2026.2.2)
- **Operator Version**: CloudNativePG v1.24+ for ARM64 support
- **Security**: Emphasize TLS, secrets management, RBAC
- **Testing**: Include validation commands for each step
- **Updates**: Document upgrade paths for Authentik and PostgreSQL

## Success Criteria

- Users can deploy working Authentik instance in <30 minutes
- Multi-user authentication works with k8s-opencode
- Documentation is parseable by AI assistants for automated setup
- Troubleshooting guides resolve 90% of common issues

## Next Steps

This design provides a complete documentation suite for Authentik in multi-user Kubernetes environments. Proceed to implementation planning.</content>
<parameter name="filePath">docs/superpowers/specs/2026-04-08-authentik-documentation-design.md