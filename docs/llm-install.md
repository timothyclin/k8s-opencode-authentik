# LLM-Assisted Authentik Installation Guide

This guide provides step-by-step instructions for LLM agents to assist humans in deploying Authentik for k8s-opencode multi-user Kubernetes environments.

## Security Requirements for AI Agents

**IMPORTANT:** AI agents must NEVER handle, store, or transmit sensitive information such as passwords, cryptographic keys, or tokens. Always generate placeholder files and cue humans to provide actual values. See https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/AGENTS.md for detailed security guidelines.

## Prerequisites Check

1. Verify system requirements using https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/prerequisites.md
   - Run: `kubectl version --client`
   - Run: `helm version`
   - Check CloudNativePG operator: `kubectl get deployment -n cnpg-system` (should show postgresql-operator-controller-manager)

2. If prerequisites not met, guide human to install missing components:
   - For kubectl/helm: Follow https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/prerequisites.md
   - For CloudNativePG: Run `kubectl apply -f https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.22.1/cnpg-1.22.1.yaml`

## Configuration Setup

**Human Action Required:** Provide the following configuration values before proceeding.

### 1. Namespace Selection
Choose the Kubernetes namespace for Authentik deployment.
- **Suggested default:** `authentik`
- **Alternative:** Use any valid namespace name (e.g., `identity`, `auth`, `security`)

Selected namespace: ________ (fill in your choice, default: `authentik`)

### 2. Storage Class Selection
Choose the Kubernetes storage class for persistent volumes.

1. First, list available storage classes:
   ```bash
   kubectl get storageclass
   ```

2. **Select storage class:** Choose from the available classes listed above. This will be used for PostgreSQL and Authentik persistent storage.
   
   Selected storage class: ________ (fill in your choice)

   **⚠️ IMPORTANT:** If no storage classes are available or you're unsure, use `standard` or contact your cluster administrator. The installation may fail if the selected storage class doesn't exist.

**IMPORTANT:** Once chosen, substitute `{{NAMESPACE}}` with your selected namespace and `{{STORAGE_CLASS}}` with your selected storage class in ALL subsequent commands and files.

## PostgreSQL Deployment

1. Deploy CloudNativePG cluster using https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/postgresql-setup.md

   Create `postgresql-cluster.yaml` from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/postgresql-cluster.yaml:
   ```bash
   curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/postgresql-cluster.yaml -o postgresql-cluster.yaml
   ```

   **Human Action Required:** Edit `postgresql-cluster.yaml` and replace:
   - `{{NAMESPACE}}` with your selected namespace
   - `{{STORAGE_CLASS}}` with your selected storage class

2. Apply the PostgreSQL cluster:
   ```bash
    # Create namespace first
    kubectl create namespace {{NAMESPACE}}
    
    # Apply cluster configuration
    kubectl apply -f postgresql-cluster.yaml
   ```

3. **Optional: Enable Tailscale Ingress** (for secure tailnet access)
   
   Check if Tailscale ingress is available:
   ```bash
   kubectl get ingressclass | grep tailscale
   ```
   
   If available, create Tailscale ingress for secure access:
   ```bash
   cat > tailscale-ingress.yaml << EOF
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: authentik-tailscale
     namespace: {{NAMESPACE}}
     annotations:
       tailscale.com/hostname: "authentik"
   spec:
     ingressClassName: tailscale
     rules:
     - http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: authentik-server
               port:
                 number: 443
   EOF
   
   kubectl apply -f tailscale-ingress.yaml
   ```
   
   Wait for Tailscale domain assignment:
   ```bash
   kubectl get ingress authentik-tailscale -n {{NAMESPACE}}
   # Look for ADDRESS column - this will be your Tailscale domain (e.g., authentik-*.ts.net)
   ```

## Authentik Installation

1. Install Authentik using official Helm chart from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/authentik-deployment.md

   Create values file from example:
   ```bash
   curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/values-official.yaml -o values.yaml
   ```

2. Generate Authentik secrets securely:
   ```bash
   # Generate secure secret key and save to file
   openssl rand -base64 32 > authentik_secret_key.txt
   
   # Create Authentik secrets file using saved passwords (no display)
   cat > values-authentik-secrets.yaml << EOF
authentik:
  secret_key: "$(cat authentik_secret_key.txt)"
  postgresql:
    password: "$(cat postgres_password.txt)"
EOF
   ```

3. Install Authentik:
   ```bash
    helm repo add authentik https://charts.goauthentik.io

    helm install authentik authentik/authentik -f values.yaml -f values-authentik-secrets.yaml --namespace {{NAMESPACE}}
   ```

4. Wait for Authentik to be ready:
   ```bash
    kubectl get pods -l app.kubernetes.io/name=authentik -n {{NAMESPACE}}
    kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=authentik -n {{NAMESPACE}} --timeout=300s
   ```
   
   **Note:** During initial setup, pods may show "Running" but not "Ready" while database migrations complete. This is normal and can take 5-10 minutes.

## Authentik Setup

1. Follow https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/authentik-setup.md to set up users, groups, and policies

2. Access Authentik admin interface:
   ```bash
    # Find the ingress URL(s)
    kubectl get ingress -l app.kubernetes.io/name=authentik -n {{NAMESPACE}}
    
    # For nginx ingress: Look for HOSTS column (e.g., authentik.local)
    # For Tailscale ingress: Look for ADDRESS column (e.g., authentik-*.ts.net)
    
    # Admin URL: https://[hostname]/admin/
    ```
    Default credentials: admin / admin (change after first login)

3. Generate OIDC client configuration:
   ```bash
   # In Authentik admin UI:
   # 1. Go to Applications > Applications
   # 2. Create new application: "k8s-opencode"
   # 3. Go to Providers > Create OAuth2/OpenID Provider
   # 4. Configure provider settings
   # 5. Copy Client ID and Client Secret
   ```
   
   Then create placeholder file:
   ```bash
   cat > oidc-secrets.yaml << 'EOF'
   # OIDC Client Configuration - replace with values from Authentik UI
   client_id: "YOUR_OIDC_CLIENT_ID_HERE"
   client_secret: "YOUR_OIDC_CLIENT_SECRET_HERE"
   EOF
   ```

   **Human Action Required:** Replace placeholders with actual Client ID and Secret from Authentik

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

1. Test Authentik login flow:
   ```bash
    # Check ingress status
    kubectl get ingress -n {{NAMESPACE}}
    
    # Test nginx ingress: curl http://authentik.local/-/health/live/
    # Test Tailscale ingress: curl https://[tailscale-domain]/-/health/live/
   ```

2. Verify OIDC integration:
   ```bash
    # Check if OIDC config was applied
    kubectl get configmaps,secrets -l app.kubernetes.io/name=authentik -n {{NAMESPACE}}
   ```

3. Test basic connectivity:
   ```bash
    # Check all pods are running
    kubectl get pods -l app.kubernetes.io/name=authentik -n {{NAMESPACE}}
   kubectl get pods -l cnpg.io/cluster
   ```

4. Run troubleshooting checks from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/troubleshooting.md if issues occur

## Error Handling

If any step fails:

1. **PostgreSQL issues**: Check `kubectl describe postgresql/<cluster-name>` and `kubectl logs deployment/postgresql-operator-controller-manager -n cnpg-system`

2. **Storage class issues**: If PostgreSQL pods are stuck in "Pending" state, check storage class availability with `kubectl get storageclass` and verify PVC creation with `kubectl get pvc -n {{NAMESPACE}}`

3. **Authentik issues**: Check `kubectl logs -l app.kubernetes.io/name=authentik -n {{NAMESPACE}} --tail=100`

4. **Prometheus CRD issues**: If Helm install fails with Prometheus errors, disable monitoring in values.yaml: `prometheus.rules.enabled: false`

5. **Ingress issues**: If web interface is inaccessible, check ingress with `kubectl get ingress -n {{NAMESPACE}}` and ensure ingress controller is running

6. **Database lock issues**: During initial setup, pods may show "Running" but not "Ready" while database migrations complete. Wait 5-10 minutes and check health endpoints.

3. **General troubleshooting**: See https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/troubleshooting.md

4. **Rollback if needed**:
   ```bash
   helm uninstall authentik --namespace {{NAMESPACE}}
   kubectl delete postgresql/<cluster-name> -n {{NAMESPACE}}
   ```