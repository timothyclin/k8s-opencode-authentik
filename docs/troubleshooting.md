# Troubleshooting

Decision tree for resolving common Authentik deployment and configuration issues.

## Deployment Issues

### PostgreSQL cluster not ready

**Symptoms:** `kubectl get cluster` shows status other than `Cluster in healthy state`

**Diagnosis:**
```bash
# Check cluster status
kubectl describe cluster authentik-db -n authentik

# Check pod status
kubectl get pods -n authentik -l cnpg.io/cluster=authentik-db

# Check logs
kubectl logs -n authentik -l cnpg.io/cluster=authentik-db --tail=50
```

**Solutions:**

1. **Storage issues**
   ```bash
   # Check PVC status
   kubectl get pvc -n authentik
   
   # Verify storage class exists
   kubectl get storageclass
   ```
   → Ensure storage class supports the requested access mode

2. **Resource constraints**
   ```bash
   # Check node resources
   kubectl describe nodes | grep -A 5 "Capacity:"
   ```
   → Increase node resources or reduce PostgreSQL resource requests

3. **Network issues**
   ```bash
   # Test DNS resolution
   kubectl exec -n authentik deployment/cnpg-controller-manager -- nslookup kubernetes.default
   ```
   → Check cluster DNS configuration

### Authentik pods crash

**Symptoms:** Authentik pods in CrashLoopBackOff

**Diagnosis:**
```bash
# Check pod status
kubectl get pods -n authentik

# Get crash details
kubectl describe pod -n authentik <authentik-pod-name>

# Check logs
kubectl logs -n authentik <authentik-pod-name> --previous
```

**Decision Tree:**

```
Pod crash detected
├── Check logs contain "Database connection failed"
│   ├── Yes → Database connection issue
│   │   ├── Check PostgreSQL service
│   │   │   kubectl get svc -n authentik
│   │   ├── Check database credentials
│   │   │   kubectl get secret authentik-postgres -n authentik -o yaml
│   │   └── Verify connection string in values.yaml
│   └── No → Continue
├── Check logs contain "Secret key invalid"
│   ├── Yes → Secret key issue
│   │   ├── Verify secret_key length (32 chars)
│   │   └── Check for special characters in secret
│   └── No → Continue
└── Check resource limits
    ├── Memory limit exceeded
    │   └── Increase memory limits in values.yaml
    └── CPU limit exceeded
        └── Increase CPU limits in values.yaml
```

### Ingress not accessible

**Symptoms:** Cannot access Authentik via browser

**Diagnosis:**
```bash
# Check ingress status
kubectl get ingress -n authentik

# Describe ingress
kubectl describe ingress authentik-server -n authentik

# Check ingress controller
kubectl get pods -n ingress-nginx
```

**Solutions:**

1. **DNS resolution**
   ```bash
   # Test DNS
   nslookup authentik.yourdomain.com
   ```
   → Add DNS record or use IP access

2. **TLS certificate**
   ```bash
   # Check certificate status
   kubectl get certificate -n authentik
   ```
   → Verify cert-manager installation and configuration

3. **Ingress class**
   ```bash
   # Check ingress class
   kubectl get ingressclass
   ```
   → Ensure correct ingress class is specified

## Configuration Issues

### Cannot log in as admin

**Symptoms:** Setup wizard doesn't appear or login fails

**Diagnosis:**
```bash
# Check bootstrap logs
kubectl logs -n authentik deployment/authentik-worker | grep bootstrap

# Check if admin user exists
kubectl exec -n authentik deployment/authentik-worker -- ak list_users
```

**Solutions:**

1. **Bootstrap not run**
   ```bash
   # Manually trigger bootstrap
   kubectl exec -n authentik deployment/authentik-worker -- ak bootstrap
   ```

2. **Wrong credentials**
   - Check `AUTHENTIK_BOOTSTRAP_PASSWORD` and `AUTHENTIK_BOOTSTRAP_EMAIL` in values.yaml
   - Reset password via command line

3. **Database not initialized**
   ```bash
   # Check database tables
   kubectl exec -n authentik deployment/authentik-worker -- ak shell -c "from django.db import connection; cursor = connection.cursor(); cursor.execute('SELECT count(*) FROM django_migrations;'); print(cursor.fetchone())"
   ```
   → Run database migrations

### OIDC provider errors

**Symptoms:** Applications cannot authenticate via OIDC

**Diagnosis:**
```bash
# Check outpost logs
kubectl logs -n authentik deployment/authentik-outpost

# Test OIDC endpoints
curl -k https://authentik.yourdomain.com/application/o/app/.well-known/openid_configuration
```

**Decision Tree:**

```
OIDC authentication failing
├── Check client credentials
│   ├── Verify client_id and client_secret
│   ├── Confirm redirect URIs match
│   ├── Check client type (confidential vs public)
├── Check provider configuration
│   ├── Verify issuer URL format
│   ├── Confirm signing key exists
│   ├── Check scopes configuration
├── Check network connectivity
│   ├── Test DNS resolution
│   ├── Verify TLS certificates
│   ├── Check firewall rules
└── Check application configuration
    ├── Verify client registration
    ├── Confirm grant types
    └── Check token validation settings
```

## Performance Issues

### Slow authentication

**Symptoms:** Login takes >5 seconds

**Diagnosis:**
```bash
# Check database performance
kubectl exec -n authentik deployment/authentik-worker -- ak shell -c "
from django.db import connection
import time
start = time.time()
cursor = connection.cursor()
cursor.execute('SELECT count(*) FROM auth_user;')
result = cursor.fetchone()
end = time.time()
print(f'DB query took {end-start:.2f}s, user count: {result[0]}')
"
```

**Solutions:**

1. **Database optimization**
   ```yaml
   # PostgreSQL tuning
   postgresql:
     primary:
       extendedConfiguration: |
         max_connections = 200
         shared_buffers = 512MB
         work_mem = 4MB
   ```

2. **Redis caching**
   ```yaml
   # Enable Redis for sessions
   authentik:
     redis:
       host: "authentik-redis"
   ```

3. **Authentik scaling**
   ```yaml
   server:
     replicas: 3
   worker:
     replicas: 2
   ```

### High memory usage

**Symptoms:** Pods restarting due to OOM

**Diagnosis:**
```bash
# Check memory usage
kubectl top pods -n authentik

# Check memory limits
kubectl get pod -n authentik -o jsonpath='{.spec.containers[*].resources}' | jq
```

**Solutions:**

1. **Increase limits**
   ```yaml
   server:
     resources:
       limits:
         memory: 1Gi
   ```

2. **Enable Gunicorn tuning**
   ```yaml
   authentik:
     web:
       workers: 2
       threads: 4
   ```

3. **Database connection pooling**
   ```yaml
   postgresql:
     primary:
       pgBouncer:
         enabled: true
   ```

## Network Issues

### Service mesh conflicts

**Symptoms:** Intermittent connectivity issues

**Diagnosis:**
```bash
# Check service mesh injection
kubectl get pod -n authentik -o jsonpath='{.metadata.annotations}' | jq

# Test service connectivity
kubectl run test --image=busybox --rm -i --restart=Never -- nslookup authentik-db-rw.authentik.svc.cluster.local
```

**Solutions:**

1. **Exclude from mesh**
   ```yaml
   # Pod annotations
   podAnnotations:
     sidecar.istio.io/inject: "false"
   ```

2. **Configure mesh policies**
   ```yaml
   # Istio DestinationRule
   apiVersion: networking.istio.io/v1beta1
   kind: DestinationRule
   metadata:
     name: authentik-db
   spec:
     host: authentik-db-rw.authentik.svc.cluster.local
     trafficPolicy:
       tls:
         mode: DISABLE
   ```

## Upgrade Issues

### Post-upgrade failures

**Symptoms:** Authentik won't start after upgrade

**Diagnosis:**
```bash
# Check migration status
kubectl exec -n authentik deployment/authentik-worker -- ak show_migrations

# Check for pending migrations
kubectl exec -n authentik deployment/authentik-worker -- ak migrate --check
```

**Solutions:**

1. **Run migrations**
   ```bash
   kubectl exec -n authentik deployment/authentik-worker -- ak migrate
   ```

2. **Clear cache**
   ```bash
   kubectl exec -n authentik deployment/authentik-worker -- ak clear_cache
   ```

3. **Rebuild search index**
   ```bash
   kubectl exec -n authentik deployment/authentik-worker -- ak rebuild_search
   ```

## Monitoring and Alerting

### Set up health checks

```yaml
# Readiness probe
readinessProbe:
  httpGet:
    path: /-/health/ready/
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10

# Liveness probe  
livenessProbe:
  httpGet:
    path: /-/health/live/
    port: http
  initialDelaySeconds: 30
  periodSeconds: 30
```

### Alert rules

```yaml
# PrometheusRule for Authentik
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: authentik-alerts
spec:
  groups:
  - name: authentik
    rules:
    - alert: AuthentikDown
      expr: up{job="authentik-server"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Authentik server is down"
```

## Getting Help

### Community Resources

1. **Authentik Discord**: https://goauthentik.io/discord
2. **GitHub Issues**: https://github.com/goauthentik/authentik/issues
3. **Documentation**: https://goauthentik.io/docs/

### Commercial Support

- **Enterprise Support**: https://goauthentik.io/pricing/
- **CloudNativePG Support**: https://cloudnative-pg.io/support/

### Debug Information

When reporting issues, include:

```bash
# System information
kubectl exec -n authentik deployment/authentik-worker -- ak version

# Configuration dump (redact secrets)
kubectl get configmap -n authentik authentik-server -o yaml

# Pod information
kubectl describe pod -n authentik <pod-name>
```