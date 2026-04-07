# OpenCode Integration

Configure Authentik as OIDC provider for OpenCode authentication.

## Setup Steps

1. **Deploy Authentik** (see main README)

2. **Create OIDC Application in Authentik**
   - Go to Authentik admin UI
   - Navigate to Applications → Create
   - Name: "OpenCode"
   - Provider: Create new OIDC provider
     - Client Type: Confidential
     - Scopes: openid, email, profile
     - Redirect URIs: `https://<opencode-domain>/oauth2/callback`

3. **Get Client Credentials**
   - Copy Client ID and Client Secret from the provider

4. **Configure OpenCode**
   In your OpenCode `values.yaml`:

   ```yaml
   auth:
     oidc:
       enabled: true
       provider: "oidc"
       clientId: "<client-id-from-authentik>"
       clientSecret: "<client-secret-from-authentik>"
       issuerUrl: "https://<authentik-domain>/application/o/opencode/"
       cookieSecret: "<generate-32-char-secret>"
       emailDomain: "*"
       hostname: "<opencode-hostname>"
   ```

5. **Deploy OpenCode**
   ```bash
   helm upgrade opencode ./chart -f values.yaml
   ```

## User Flow

1. User visits OpenCode URL
2. Redirected to Authentik login
3. After authentication, redirected back to OpenCode
4. User has access based on Authentik permissions