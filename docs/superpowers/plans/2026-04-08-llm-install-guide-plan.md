# LLM Install Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add LLM installation instructions for Authentik deployment guidance

**Architecture:** Create docs/llm-install.md with step-by-step guide, update README.md with Quick Start, add security section to AGENTS.md

**Tech Stack:** Markdown documentation

---

### Task 1: Create LLM Install Guide

**Files:**
- Create: `docs/llm-install.md`

- [ ] **Step 1: Write the content for docs/llm-install.md**

```markdown
# LLM-Assisted Authentik Installation Guide

This guide provides step-by-step instructions for LLM agents to assist humans in deploying Authentik for k8s-opencode multi-user Kubernetes environments.

## Security Requirements for AI Agents

**IMPORTANT:** AI agents must NEVER handle, store, or transmit sensitive information such as passwords, cryptographic keys, or tokens. Always generate placeholder files and cue humans to provide actual values. See AGENTS.md for detailed security guidelines.

## Prerequisites Check

1. Verify system requirements using `docs/prerequisites.md`
   - Run: `kubectl version --client`
   - Run: `helm version`
   - Ensure CloudNativePG operator is available

2. If prerequisites not met, guide human to install missing components

## PostgreSQL Deployment

1. Deploy CloudNativePG cluster using `docs/postgresql-setup.md`

   Create `postgresql-cluster.yaml` from `docs/examples/postgresql-cluster.yaml`:
   ```bash
   cp docs/examples/postgresql-cluster.yaml postgresql-cluster.yaml
   ```

2. Generate secrets placeholder file:
   ```bash
   cat > values-postgres-secrets.yaml << 'EOF'
   # Replace YOUR_DATABASE_PASSWORD_HERE with your actual database password
   # Generate a strong password and replace the placeholder
   postgresql:
     auth:
       postgresPassword: "YOUR_DATABASE_PASSWORD_HERE"
       username: "authentik"
       password: "YOUR_DATABASE_PASSWORD_HERE"
       database: "authentik"
   EOF
   ```

   **Human Action Required:** Replace `YOUR_DATABASE_PASSWORD_HERE` with actual passwords in `values-postgres-secrets.yaml`

3. Apply the PostgreSQL cluster:
   ```bash
   kubectl apply -f postgresql-cluster.yaml
   ```

4. Wait for PostgreSQL to be ready:
   ```bash
   kubectl get postgresql
   ```

## Authentik Installation

1. Install Authentik using official Helm chart from `docs/authentik-deployment.md`

   Create values file from example:
   ```bash
   cp docs/examples/values-official.yaml values.yaml
   ```

2. Generate secrets placeholder file:
   ```bash
   cat > values-authentik-secrets.yaml << 'EOF'
   # Replace placeholders with actual secret values
   authentik:
     secret_key: "YOUR_AUTHENTIK_SECRET_KEY_HERE"  # Generate a long random string
     postgresql:
       password: "YOUR_DATABASE_PASSWORD_HERE"  # Must match PostgreSQL password
   EOF
   ```

   **Human Action Required:** Replace placeholders in `values-authentik-secrets.yaml`

3. Install Authentik:
   ```bash
   helm repo add authentik https://charts.goauthentik.io
   helm repo update
   helm install authentik authentik/authentik -f values.yaml -f values-authentik-secrets.yaml
   ```

4. Wait for Authentik to be ready:
   ```bash
   kubectl get pods -l app.kubernetes.io/name=authentik
   ```

## Multi-User Configuration

1. Follow `docs/multi-user-config.md` to set up users, groups, and policies

2. Access Authentik admin interface (URL from ingress)

3. Generate OIDC secrets placeholder:
   ```bash
   cat > oidc-secrets.yaml << 'EOF'
   # OIDC Client Configuration
   client_id: "YOUR_OIDC_CLIENT_ID_HERE"
   client_secret: "YOUR_OIDC_CLIENT_SECRET_HERE"
   EOF
   ```

   **Human Action Required:** Configure OIDC client in Authentik UI, then replace placeholders

## OIDC Integration

1. Configure k8s-opencode integration using `docs/oidc-integration.md`

2. Update `docs/examples/oidc-client-config.yaml` with actual values

3. Apply OIDC configuration:
   ```bash
   kubectl apply -f oidc-client-config.yaml
   ```

## Validation

1. Test Authentik login flow
2. Verify OIDC integration with k8s-opencode
3. Run troubleshooting checks from `docs/troubleshooting.md` if issues occur

## Cleanup

Remove placeholder files after installation:
```bash
rm values-postgres-secrets.yaml values-authentik-secrets.yaml oidc-secrets.yaml
```
```

- [ ] **Step 2: Commit**

```bash
git add docs/llm-install.md
git commit -m "docs: add LLM install guide for Authentik deployment"
```

### Task 2: Update README Quick Start

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Quick Start instruction for LLM agents**

In the Quick Start section, add before the numbered steps:

```markdown
### For AI-Assisted Installation

Tell your LLM agent: "Follow the instructions in docs/llm-install.md to install Authentik for k8s-opencode"
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add LLM Quick Start instruction to README"
```

### Task 3: Add Security Section to AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Add LLM Installation Security section**

Add after the existing sections:

```markdown
## LLM Installation Security

Guidelines for AI agents assisting with Authentik installation:

### Handling Sensitive Information

- **NEVER** read, store, or transmit passwords, cryptographic keys, tokens, or other secrets
- **NEVER** accept secrets provided directly by users in conversation
- **ALWAYS** generate placeholder files with obvious placeholders like `YOUR_SECRET_HERE`
- **ALWAYS** cue humans to replace placeholders with actual values
- **ALWAYS** instruct humans to delete placeholder files after use

### Placeholder File Creation

When secrets are required:
1. Create a YAML file with placeholder values
2. Clearly comment what each placeholder represents
3. Instruct the human to replace placeholders
4. Reference this file in commands using `-f filename.yaml`

### Example

```yaml
# values-secrets.yaml
authentik:
  secret_key: "YOUR_AUTHENTIK_SECRET_KEY_HERE"  # Generate 50+ character random string
  postgresql:
    password: "YOUR_DATABASE_PASSWORD_HERE"    # Must match PostgreSQL setup
```

Human must replace `YOUR_*_HERE` values before proceeding.

### Validation

After placeholder replacement:
- Verify files exist and placeholders are replaced
- Do not inspect file contents for actual secret values
- Proceed with installation using the updated files
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: add LLM installation security guidelines to AGENTS"
```