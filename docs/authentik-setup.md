# Authentik Setup

Set up tenants, users, groups, and policies for multi-user k8s-opencode environments.

## Access Admin Interface

1. Navigate to `https://authentik.yourdomain.com/admin/`
2. Log in with admin credentials
3. Access the Admin interface

## Create User Sources

### LDAP Source (for existing directory)

```yaml
# Via Admin UI: Directory > User Sources > Create
# Or via API
apiVersion: goauthentik.io/v1
kind: LDAPSource
metadata:
  name: company-ldap
spec:
  serverUri: "ldap://ldap.company.com"
  bindDn: "cn=authentik,ou=service,dc=company,dc=com"
  bindPassword: "ldap-password"
  baseDn: "dc=company,dc=com"
  userObjectFilter: "(objectClass=person)"
  groupObjectFilter: "(objectClass=group)"
```

### OAuth Source (Google, GitHub, etc.)

```yaml
# Via Admin UI: Directory > User Sources > Create OAuth Source
apiVersion: goauthentik.io/v1
kind: OAuthSource
metadata:
  name: github-oauth
spec:
  providerType: "github"
  consumerKey: "your-github-oauth-app-id"
  consumerSecret: "your-github-oauth-app-secret"
  authorizationUrl: "https://github.com/login/oauth/authorize"
  accessTokenUrl: "https://github.com/login/oauth/access_token"
  profileUrl: "https://api.github.com/user"
```

## Set Up Tenants

For multi-tenant environments:

```yaml
# Via Admin UI: Administration > Tenants > Create
apiVersion: goauthentik.io/v1
kind: Tenant
metadata:
  name: tenant-a
spec:
  domain: "tenant-a.yourdomain.com"
  default: false
  branding:
    title: "Tenant A Portal"
    logo: "/media/tenant-a-logo.png"
```

## Create Groups and Roles

```yaml
# Via Admin UI: Directory > Groups > Create
apiVersion: goauthentik.io/v1
kind: Group
metadata:
  name: k8s-admins
spec:
  name: "Kubernetes Administrators"
  users: ["user1", "user2"]
  attributes:
    kubernetes_roles: ["cluster-admin"]
```

## Configure Policies

### Role-Based Access Policy

```yaml
# Via Admin UI: Policies > Create Policy > Event Matcher
apiVersion: goauthentik.io/v1
kind: Policy
metadata:
  name: admin-role-policy
spec:
  executionLogging: true
  expressions:
    - expression: |
        # Check if user has admin role
        if "admin" in user.group_attributes().get("roles", []):
            return True
        return False
```

### Time-Based Access Policy

```yaml
# Via Admin UI: Policies > Create Policy > Event Matcher
apiVersion: goauthentik.io/v1
kind: Policy
metadata:
  name: business-hours-policy
spec:
  executionLogging: true
  expressions:
    - expression: |
        from datetime import datetime
        now = datetime.now()
        # Allow access Monday-Friday, 9 AM - 6 PM
        if now.weekday() < 5 and 9 <= now.hour < 18:
            return True
        return False
```

## Set Up Applications

### Kubernetes Dashboard Application

```yaml
# Via Admin UI: Applications > Applications > Create
apiVersion: goauthentik.io/v1
kind: Application
metadata:
  name: kubernetes-dashboard
spec:
  name: "Kubernetes Dashboard"
  slug: "k8s-dashboard"
  provider: "oidc-provider-ref"
  group: "kubernetes"
  meta:
    description: "Access Kubernetes cluster resources"
  openInNewTab: true
```

## Configure Flows

### Authentication Flow

```yaml
# Via Admin UI: Flows > Create Flow
apiVersion: goauthentik.io/v1
kind: Flow
metadata:
  name: default-authentication
spec:
  name: "Default Authentication"
  title: "Welcome back!"
  designation: "authentication"
  slug: "default-authentication-flow"
  policyEngineMode: "any"
  stages:
    - name: "identification"
      kind: "identification"
      order: 10
    - name: "password"
      kind: "password"
      order: 20
    - name: "login"
      kind: "login"
      order: 30
```

### Enrollment Flow

```yaml
# Via Admin UI: Flows > Create Flow
apiVersion: goauthentik.io/v1
kind: Flow
metadata:
  name: default-enrollment
spec:
  name: "Default Enrollment"
  title: "Create your account"
  designation: "enrollment"
  slug: "default-enrollment-flow"
  stages:
    - name: "welcome"
      kind: "user_login"
      order: 10
    - name: "email"
      kind: "email"
      order: 20
    - name: "password"
      order: 30
```

## User Self-Service

Enable user self-management:

```yaml
# Via Admin UI: Administration > Settings > User settings
selfService:
  changeUsername: true
  changeEmail: true
  changeName: true
  changePassword: true
  mfa:
    totp: true
    webauthn: true
    recoveryCodes: true
```

## Monitoring and Auditing

### Enable Audit Logging

```yaml
# Via Admin UI: Administration > Settings > System
audit:
  enabled: true
  retention: "90 days"
```

### Set Up Notifications

```yaml
# Via Admin UI: Events > Notification Rules > Create
apiVersion: goauthentik.io/v1
kind: NotificationRule
metadata:
  name: failed-login-alert
spec:
  name: "Failed Login Alert"
  group: "security"
  triggers:
    - event: "authentik.events.auth.failed_login"
  transports:
    - email
  severity: "warning"
```

## Scaling Considerations

For large multi-user deployments:

- **Database**: Use PostgreSQL read replicas
- **Redis**: Enable Redis clustering
- **Authentik**: Scale server/worker replicas
- **Caching**: Configure Redis for session storage
- **Load Balancing**: Use ingress controller with session affinity

## Troubleshooting

### Users can't authenticate

```bash
# Check flow execution logs
kubectl logs -n authentik deployment/authentik-worker | grep "flow_execution"

# Verify user source connectivity
kubectl exec -n authentik deployment/authentik-worker -- ak test-ldap
```

### Policy not applying

```bash
# Check policy evaluation logs
kubectl logs -n authentik deployment/authentik-worker | grep "policy_evaluation"

# Test policy via Admin UI
# Administration > Policies > Test Policy
```

### Application access issues

```bash
# Check outpost logs
kubectl logs -n authentik deployment/authentik-outpost

# Verify OIDC configuration
kubectl get oauthclient -n authentik
```