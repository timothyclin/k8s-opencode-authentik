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

## Ingress Configuration

This section configures how Authentik will be accessed from outside the cluster.

### 1. Detect Available Ingress Classes

List available ingress classes in your cluster:
```bash
kubectl get ingressclass
```

**Expected output example:**
```
NAME       CONTROLLER                     PARAMETERS   AGE
nginx      k8s.io/ingress-nginx           <none>       30d
tailscale  tailscale.com/ts-ingress       <none>       7d
traefik    traefik.io/ingress-controller  <none>       15d
```

### 2. Choose Ingress Class

Based on the available classes above:

- **If `tailscale` is available:** Recommended for secure, short domain access
- **If `nginx` is available:** Good for public-facing deployments
- **If `traefik` is available:** Alternative ingress controller
- **If none available:** Skip ingress configuration (use port-forwarding)

**Selected ingress class:** ________ (fill in: tailscale, nginx, traefik, or none)

### 3. Configure Hostname

#### For Tailscale Ingress:
**Recommended hostname:** `auth`

This will create the URL: `auth.{your-tailnet}.ts.net`

**Human Action Required:** Confirm your Tailscale tailnet name (found in Tailscale admin console or `tailscale status` command).

**Your tailnet name:** ________ (e.g., mycompany, personal)

**Resulting URL:** auth.{{TAILNET}}.ts.net

**Custom hostname (optional):** ________ (leave blank to use 'auth', or enter custom like 'idp', 'login')

#### For Other Ingress Classes:
**Hostname:** ________ (e.g., authentik.yourdomain.com)

### 4. Validate Configuration

**IMPORTANT:** Hostname must be:
- 1-63 characters long
- Contain only lowercase letters, numbers, and hyphens
- Start and end with alphanumeric characters
- Not contain spaces or special characters

**Validation check:**
```bash
# Test hostname format (replace YOUR_HOSTNAME)
hostname="YOUR_HOSTNAME"
if [[ "$hostname" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] && [ ${#hostname} -le 63 ]; then
  echo "✓ Valid hostname"
else
  echo "✗ Invalid hostname - please choose a different name"
fi
```

**IMPORTANT:** Once chosen, substitute `{{INGRESS_CLASS}}` with your selected ingress class and `{{INGRESS_HOST}}` with your hostname in ALL subsequent commands and files.

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

    **IMPORTANT:** If no storage classes are available or you're unsure, use `standard` or contact your cluster administrator. The installation may fail if the selected storage class doesn't exist.

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

3. #### Configure Ingress (if selected)

   Create ingress configuration file (skip if INGRESS_CLASS is "none"):
   ```bash
   INGRESS_CLASS="{{INGRESS_CLASS}}"
   INGRESS_HOST="{{INGRESS_HOST}}"
   NAMESPACE="{{NAMESPACE}}"
   
   # Validate required variables
   if [ -z "$NAMESPACE" ] || [ -z "$INGRESS_CLASS" ] || [ -z "$INGRESS_HOST" ]; then
     echo "Error: Required variables NAMESPACE, INGRESS_CLASS, or INGRESS_HOST not set"
     exit 1
   fi
   
   if [ "$INGRESS_CLASS" != "none" ]; then
     # Check if ingress class is available
     if ! kubectl get ingressclass $INGRESS_CLASS >/dev/null 2>&1; then
       echo "Error: Ingress class '$INGRESS_CLASS' is not available in the cluster"
       exit 1
     fi
   
     # Generate YAML content
     cat > ingress.yaml << EOF
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: authentik
     namespace: $NAMESPACE
   EOF
   
     # For Tailscale ingress, add specific annotations
     if [ "$INGRESS_CLASS" = "tailscale" ]; then
       cat >> ingress.yaml << EOF
     annotations:
       tailscale.com/tags: "tag:k8s"
   EOF
     fi
   
     cat >> ingress.yaml << EOF
   spec:
     ingressClassName: $INGRESS_CLASS
   EOF
   
     # For Tailscale ingress, add TLS configuration
     if [ "$INGRESS_CLASS" = "tailscale" ]; then
       cat >> ingress.yaml << EOF
     tls:
     - hosts:
       - $INGRESS_HOST
   EOF
     fi
   
     cat >> ingress.yaml << EOF
     rules:
     - host: $INGRESS_HOST
       http:
         paths:
         - path: /
           pathType: ImplementationSpecific
           backend:
             service:
               name: authentik-server
               port:
                 name: https
   EOF
   
     # For nginx ingress, add TLS with secret
     if [ "$INGRESS_CLASS" = "nginx" ]; then
       cat >> ingress.yaml << EOF
     tls:
     - hosts:
       - $INGRESS_HOST
       secretName: authentik-tls
   EOF
     fi
   
     # Validate YAML syntax
     if ! kubectl apply --dry-run=client -f ingress.yaml >/dev/null 2>&1; then
       echo "Error: Generated ingress.yaml has invalid YAML syntax"
       exit 1
     fi
   
     # Apply the ingress
     kubectl apply -f ingress.yaml
   
     # For Tailscale, wait for domain assignment
     if [ "$INGRESS_CLASS" = "tailscale" ]; then
       echo "Wait for domain assignment:"
       kubectl get ingress authentik -n $NAMESPACE
       echo "# Look for ADDRESS column - this will be your full URL (e.g., auth.{tailnet}.ts.net)"
     fi
   else
     echo "Skipping ingress creation since INGRESS_CLASS is 'none'"
   fi
   ```

## Authentik Installation

1. Install Authentik using official Helm chart from https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/authentik-deployment.md

    Create values file from example and configure ingress:
    ```bash
    curl -s https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/examples/values-official.yaml -o values.yaml

    # Configure ingress via Helm values (skip if INGRESS_CLASS is "none")
    INGRESS_CLASS="{{INGRESS_CLASS}}"
    INGRESS_HOST="{{INGRESS_HOST}}"

    if [ "$INGRESS_CLASS" != "none" ]; then
      # Add ingress configuration to values.yaml
      cat >> values.yaml << EOF

# Ingress configuration
ingress:
  enabled: true
  className: "$INGRESS_CLASS"
  hosts:
    - host: $INGRESS_HOST
      paths:
        - path: /
          pathType: Prefix
EOF

      if [ "$INGRESS_CLASS" = "tailscale" ]; then
        cat >> values.yaml << EOF
  annotations:
    tailscale.com/tags: "tag:k8s"
  tls:
    - hosts:
        - $INGRESS_HOST
EOF
      fi

      if [ "$INGRESS_CLASS" = "nginx" ]; then
        cat >> values.yaml << EOF
  tls:
    - secretName: authentik-tls
      hosts:
        - $INGRESS_HOST
EOF
      fi
    fi
    ```

2. Generate Authentik secrets securely:

    **Human Action Required:** Create the following files with actual secret values (do NOT commit these files to version control):

    ```bash
    # Create placeholder for Authentik secret key (generate 50+ character random string)
    cat > authentik_secret_key.txt << 'EOF'
    YOUR_AUTHENTIK_SECRET_KEY_HERE
    EOF
    
    # Create placeholder for PostgreSQL password
    cat > postgres_password.txt << 'EOF'
    YOUR_DATABASE_PASSWORD_HERE
    EOF
    
    # Create Authentik secrets file (replace placeholders with actual values)
    cat > values-authentik-secrets.yaml << 'EOF'
    authentik:
      secret_key: "YOUR_AUTHENTIK_SECRET_KEY_HERE"
      postgresql:
        password: "YOUR_DATABASE_PASSWORD_HERE"
    EOF
    ```

    **IMPORTANT:** Replace `YOUR_AUTHENTIK_SECRET_KEY_HERE` and `YOUR_DATABASE_PASSWORD_HERE` with actual secure values. Never commit these files.

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
   
   # If using Tailscale ingress: Look for ADDRESS column
   # Your admin URL: https://{{INGRESS_HOST}}.{{TAILNET}}.ts.net/admin/
   #
   # If using other ingress: Look for HOSTS column
   # Your admin URL: https://{{INGRESS_HOST}}/admin/
   
   Default credentials: admin / admin (change after first login)
   ```

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
   
   {{- if eq .IngressClass "tailscale" }}
   # Test Tailscale ingress
   curl -k https://{{INGRESS_HOST}}.{{TAILNET}}.ts.net/-/health/live/
   {{- else }}
   # Test other ingress
   curl https://{{INGRESS_HOST}}/-/health/live/
   {{- end }}
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

7. **General troubleshooting**: See https://raw.githubusercontent.com/timothyclin/k8s-opencode-authentik/main/docs/troubleshooting.md

8. **Rollback if needed**:
   ```bash
   helm uninstall authentik --namespace {{NAMESPACE}}
   kubectl delete postgresql/<cluster-name> -n {{NAMESPACE}}
   ```