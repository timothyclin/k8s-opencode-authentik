# 2026-04-08 LLM Install Guide Design

## Overview
Add LLM installation instructions to enable AI agents to guide humans through Authentik deployment in k8s-opencode environments. This consists of:

1. New file `docs/llm-install.md` with step-by-step installation guide for LLM agents
2. Updated README.md with Quick Start instruction for humans to use LLM agents
3. New section in AGENTS.md with security requirements for opencode agents handling secrets

## Structure
The `docs/llm-install.md` guide follows the existing documentation flow:

1. **Prerequisites Check** - Verify system requirements using docs/prerequisites.md
2. **PostgreSQL Deployment** - Deploy CloudNativePG using docs/postgresql-setup.md and examples/postgresql-cluster.yaml
3. **Authentik Installation** - Install Helm chart using docs/authentik-deployment.md and values-official.yaml
4. **Configuration** - Set up multi-user config via docs/multi-user-config.md
5. **OIDC Integration** - Configure k8s-opencode integration using docs/oidc-integration.md

Each step includes commands, validation checks, and references to existing docs/examples.

## Security Handling
For steps requiring secrets:
- Generate placeholder files (e.g., `values-secrets.yaml`) with obvious placeholders like `YOUR_DATABASE_PASSWORD_HERE`
- Cue humans to replace placeholders without displaying or handling actual secrets
- LLM agents never read, store, or transmit sensitive information

## Integration
- README.md gets Quick Start instruction: "Tell your LLM agent: 'Follow docs/llm-install.md to install Authentik for k8s-opencode'"
- AGENTS.md gets "LLM Installation Security" section with requirements for opencode agents
- docs/llm-install.md references AGENTS.md security guidelines

## Implementation Notes
- Mirrors k8s-opencode repo's approach with standalone install guides
- Maintains separation between maintenance guidelines (AGENTS.md) and user installation guidance
- Ensures all secrets are handled by humans only, with clear placeholder mechanisms