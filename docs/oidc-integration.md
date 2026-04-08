# OIDC Integration with k8s-opencode

Configure k8s-opencode to use Authentik as OIDC identity provider.

## k8s-opencode OIDC Configuration

k8s-opencode supports OIDC authentication for multi-user access control.

### Get OIDC Credentials from Authentik

1. **Create OIDC Provider** in Authentik Admin:
   - Applications > Providers > Create OIDC Provider
   - Client ID: `k8s-opencode` (or generate)
   - Client Secret: Generate secure secret
   - Redirect URIs: `https://k8s-opencode.yourdomain.com/oauth2/callback`
   - Scopes: `openid`, `email`, `profile`, `groups`

2. **Create OIDC Application**:
   - Applications > Applications > Create
   - Provider: Select the OIDC provider above
   - Launch URL: `https://k8s-opencode.yourdomain.com`

3. **Note the URLs**:
   - Issuer URL: `https://authentik.yourdomain.com/application/o/k8s-opencode/`
   - Client ID: From provider settings
   - Client Secret: From provider settings

### Configure k8s-opencode

```yaml
# k8s-opencode values.yaml
opencode:
  auth:
    oidc:
      enabled: true
      issuerUrl: "https://authentik.yourdomain.com/application/o/k8s-opencode/"
      clientId: "k8s-opencode"
      clientSecret: "your-client-secret"
      redirectUrl: "https://k8s-opencode.yourdomain.com/oauth2/callback"
      scopes:
        - openid
        - email
        - profile
        - groups
      usernameClaim: "preferred_username"
      emailClaim: "email"
      groupsClaim: "groups"
      usernamePrefix: "oidc:"
      groupPrefix: "oidc:"
```

### Kubernetes RBAC Integration

Create ClusterRoleBindings for OIDC groups:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oidc-cluster-admin
subjects:
- kind: Group
  name: "oidc:cluster-admins"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oidc-developer
subjects:
- kind: Group
  name: "oidc:developers"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
```

### Authentik Group Mapping

Create groups in Authentik that match Kubernetes RBAC:

```yaml
# Via Authentik Admin UI: Directory > Groups > Create
apiVersion: goauthentik.io/v1
kind: Group
metadata:
  name: cluster-admins
spec:
  name: "Cluster Administrators"
  attributes:
    kubernetes_groups: ["oidc:cluster-admins"]
  users: ["admin-user"]
---
apiVersion: goauthentik.io/v1
kind: Group
metadata:
  name: developers
spec:
  name: "Developers"
  attributes:
    kubernetes_groups: ["oidc:developers"]
  users: ["dev-user1", "dev-user2"]
```

## Advanced OIDC Features

### User Attribute Mapping

Map Authentik user attributes to Kubernetes claims:

```yaml
# k8s-opencode values.yaml
opencode:
  auth:
    oidc:
      # Map Authentik groups to Kubernetes groups
      groupsClaim: "groups"
      groupPrefix: "oidc:"
      
      # Custom claims
      extraScopes:
        - "custom_claims"
      customClaimMappings:
        department: "department"
        employee_id: "employeeId"
```

### Multi-Tenant Setup

For multiple k8s-opencode instances:

1. **Create separate OIDC applications** in Authentik for each tenant
2. **Use tenant-specific groups** for access control
3. **Configure separate issuer URLs** per tenant

```yaml
# Tenant-specific configuration
opencode:
  tenantA:
    auth:
      oidc:
        issuerUrl: "https://authentik.yourdomain.com/application/o/tenant-a/"
        clientId: "tenant-a-client"
        
  tenantB:
    auth:
      oidc:
        issuerUrl: "https://authentik.yourdomain.com/application/o/tenant-b/"
        clientId: "tenant-b-client"
```

## Outpost Deployment

Deploy Authentik outposts for advanced proxy features:

```yaml
# Via Authentik Admin UI: Applications > Outposts > Create
apiVersion: goauthentik.io/v1
kind: Outpost
metadata:
  name: k8s-opencode-proxy
spec:
  type: "proxy"
  protocol: "https"
  applications:
    - name: "k8s-opencode"
  config:
    kubernetes:
      namespace: "k8s-opencode"
      ingress_class: "nginx"
```

## Security Considerations

### Token Validation

Ensure proper token validation:

```yaml
opencode:
  auth:
    oidc:
      # Validate tokens
      skipTLSVerify: false
      caFile: "/etc/ssl/certs/ca-certificates.crt"
      
      # Token refresh
      refreshToken: true
      refreshInterval: "30m"
```

### Session Management

Configure session timeouts:

```yaml
opencode:
  auth:
    oidc:
      # Session settings
      session:
        maxAge: "24h"
        inactivityTimeout: "1h"
```

## Troubleshooting

### Authentication failures

```bash
# Check k8s-opencode logs
kubectl logs -n k8s-opencode deployment/opencode

# Check Authentik outpost logs
kubectl logs -n authentik deployment/authentik-outpost

# Verify OIDC configuration
curl -k https://authentik.yourdomain.com/.well-known/openid_configuration
```

### Group mapping issues

```bash
# Check user group claims
kubectl exec -n k8s-opencode deployment/opencode -- cat /var/log/opencode/oidc.log

# Verify Authentik group attributes
# Admin UI: Directory > Users > [user] > Attributes
```

### Token refresh problems

```bash
# Check token expiry
kubectl exec -n k8s-opencode deployment/opencode -- opencode auth check-token

# Verify refresh token flow
# Network tab in browser dev tools during login
```

## Performance Tuning

For high-traffic environments:

```yaml
# Authentik OIDC provider settings
authentik:
  oidc:
    accessTokenValidity: "1h"
    refreshTokenValidity: "24h"
    idTokenValidity: "10m"
    
# k8s-opencode settings
opencode:
  auth:
    oidc:
      cache:
        enabled: true
        size: "100MB"
        ttl: "1h"
```

## Migration from Other Providers

### From Keycloak

```bash
# Update issuer URL and client credentials
opencode:
  auth:
    oidc:
      issuerUrl: "https://authentik.yourdomain.com/application/o/k8s-opencode/"
      clientId: "k8s-opencode"
      clientSecret: "new-secret"
      
      # Update claim mappings if needed
      usernameClaim: "preferred_username"  # vs Keycloak's "sub"
      groupsClaim: "groups"
```

### From Dex

```bash
# Dex typically uses different endpoints
opencode:
  auth:
    oidc:
      issuerUrl: "https://authentik.yourdomain.com/application/o/k8s-opencode/"
      # Dex uses /dex path, Authentik uses /application/o/
```