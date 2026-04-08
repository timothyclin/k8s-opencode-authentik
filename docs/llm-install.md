# LLM-Assisted Authentik Installation Guide

This guide provides step-by-step instructions for LLM agents to assist humans in deploying Authentik for k8s-opencode multi-user Kubernetes environments.

## Security Requirements for AI Agents

**IMPORTANT:** AI agents must NEVER handle, store, or transmit sensitive information such as passwords, cryptographic keys, or tokens. Always generate placeholder files and cue humans to provide actual values. See https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/AGENTS.md for detailed security guidelines.

## Prerequisites Check

1. Verify system requirements using https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/prerequisites.md
   - Run: `kubectl version --client`
   - Run: `helm version`
   - Ensure CloudNativePG operator is available

2. If prerequisites not met, guide human to install missing components

## PostgreSQL Deployment

1. Deploy CloudNativePG cluster using https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/postgresql-setup.md

   Create `postgresql-cluster.yaml` from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/postgresql-cluster.yaml:
   ```bash
   curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/postgresql-cluster.yaml -o postgresql-cluster.yaml
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

1. Install Authentik using official Helm chart from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/authentik-deployment.md

   Create values file from example:
   ```bash
   curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/values-official.yaml -o values.yaml
   ```

2. Generate secrets placeholder file:
   ```bash
   cat > values-authentik-secrets.yaml << 'EOF'
   # Replace placeholders with actual secret values
   authentik:
     secret_key: "YOUR_AUTHENTIK_SECRET_KEY_HERE"  # Generate 50+ character random string
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

## Authentik Setup

1. Follow https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/authentik-setup.md to set up users, groups, and policies

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

1. Configure k8s-opencode integration using https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/oidc-integration.md

2. Update https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/oidc-client-config.yaml with actual values:
   ```bash
   curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/oidc-client-config.yaml -o oidc-client-config.yaml
   ```

3. Apply OIDC configuration:
   ```bash
   kubectl apply -f oidc-client-config.yaml
   ```

## Validation

1. Test Authentik login flow
2. Verify OIDC integration with k8s-opencode
3. Run troubleshooting checks from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/troubleshooting.md if issues occur

## Cleanup

Remove placeholder files after installation:
```bash
rm values-postgres-secrets.yaml values-authentik-secrets.yaml oidc-secrets.yaml
```