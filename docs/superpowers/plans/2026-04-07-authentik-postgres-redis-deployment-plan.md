# Authentik PostgreSQL and Redis Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add PostgreSQL and Redis deployments to the Authentik Helm chart for a complete self-contained solution.

**Architecture:** Deploy PostgreSQL and Redis as StatefulSets with optional persistence, using existing configuration values for conditional deployment and resource management.

**Tech Stack:** Kubernetes StatefulSets, PVCs, Helm templating.

---

### Task 1: Create PostgreSQL StatefulSet Template

**Files:**
- Create: `charts/authentik/templates/postgres-statefulset.yaml`

- [ ] **Step 1: Create the postgres-statefulset.yaml template file with conditional deployment**

```yaml
{{- if .Values.postgres.enabled }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "authentik.fullname" . }}-postgres
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: postgresql
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Values.postgres.image.tag | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    helm.sh/chart: {{ include "authentik.chart" . }}
spec:
  serviceName: {{ include "authentik.fullname" . }}-postgres
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: postgresql
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: postgresql
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      containers:
      - name: postgres
        image: {{ .Values.postgres.image.repository }}:{{ .Values.postgres.image.tag }}
        env:
        - name: POSTGRES_DB
          value: authentik
        - name: POSTGRES_USER
          value: authentik
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "authentik.fullname" . }}-postgres
              key: password
        ports:
        - containerPort: 5432
          name: postgres
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
{{ toYaml .Values.postgres.resources | indent 10 }}
      volumes:
      - name: postgres-data
        {{- if .Values.postgres.persistence.enabled }}
        persistentVolumeClaim:
          claimName: {{ include "authentik.fullname" . }}-postgres
        {{- else }}
        emptyDir: {}
        {{- end }}
{{- if .Values.postgres.persistence.enabled }}
  volumeClaimTemplates:
  - metadata:
      name: {{ include "authentik.fullname" . }}-postgres
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: {{ .Values.postgres.persistence.size }}
{{- end }}
{{- end }}
```

- [ ] **Step 2: Validate PostgreSQL StatefulSet template with Helm**

Run: `helm template test ./charts/authentik --set postgres.enabled=true --dry-run`
Expected: PostgreSQL StatefulSet rendered with correct labels, environment variables, and volumes

- [ ] **Step 3: Commit PostgreSQL StatefulSet template**

```bash
git add charts/authentik/templates/postgres-statefulset.yaml
git commit -m "feat: add PostgreSQL StatefulSet template"
```

### Task 2: Create PostgreSQL Service Template

**Files:**
- Create: `charts/authentik/templates/postgres-service.yaml`

- [ ] **Step 1: Create the postgres-service.yaml template file**

```yaml
{{- if .Values.postgres.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "authentik.fullname" . }}-postgres
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: postgresql
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Values.postgres.image.tag | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    helm.sh/chart: {{ include "authentik.chart" . }}
spec:
  ports:
  - port: 5432
    targetPort: 5432
    protocol: TCP
    name: postgres
  selector:
    app.kubernetes.io/name: postgresql
    app.kubernetes.io/instance: {{ .Release.Name }}
  type: ClusterIP
{{- end }}
```

- [ ] **Step 2: Validate PostgreSQL Service template with Helm**

Run: `helm template test ./charts/authentik --set postgres.enabled=true --dry-run | grep -A 20 "kind: Service"`
Expected: PostgreSQL Service rendered with correct port and selector

- [ ] **Step 3: Commit PostgreSQL Service template**

```bash
git add charts/authentik/templates/postgres-service.yaml
git commit -m "feat: add PostgreSQL Service template"
```

### Task 3: Create Redis StatefulSet Template

**Files:**
- Create: `charts/authentik/templates/redis-statefulset.yaml`

- [ ] **Step 1: Create the redis-statefulset.yaml template file**

```yaml
{{- if .Values.redis.enabled }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "authentik.fullname" . }}-redis
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: redis
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Values.redis.image.tag | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    helm.sh/chart: {{ include "authentik.chart" . }}
spec:
  serviceName: {{ include "authentik.fullname" . }}-redis
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: redis
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: redis
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      containers:
      - name: redis
        image: {{ .Values.redis.image.repository }}:{{ .Values.redis.image.tag }}
        command: ["redis-server", "--requirepass", "$(REDIS_PASSWORD)"]
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "authentik.fullname" . }}-redis
              key: password
        ports:
        - containerPort: 6379
          name: redis
        resources:
{{ toYaml .Values.redis.resources | indent 10 }}
      volumes:
      - name: redis-data
        emptyDir: {}
{{- end }}
```

- [ ] **Step 2: Validate Redis StatefulSet template with Helm**

Run: `helm template test ./charts/authentik --set redis.enabled=true --dry-run | grep -A 30 "name: redis"`
Expected: Redis StatefulSet rendered with correct command, environment, and resources

- [ ] **Step 3: Commit Redis StatefulSet template**

```bash
git add charts/authentik/templates/redis-statefulset.yaml
git commit -m "feat: add Redis StatefulSet template"
```

### Task 4: Create Redis Service Template

**Files:**
- Create: `charts/authentik/templates/redis-service.yaml`

- [ ] **Step 1: Create the redis-service.yaml template file**

```yaml
{{- if .Values.redis.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "authentik.fullname" . }}-redis
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: redis
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Values.redis.image.tag | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    helm.sh/chart: {{ include "authentik.chart" . }}
spec:
  ports:
  - port: 6379
    targetPort: 6379
    protocol: TCP
    name: redis
  selector:
    app.kubernetes.io/name: redis
    app.kubernetes.io/instance: {{ .Release.Name }}
  type: ClusterIP
{{- end }}
```

- [ ] **Step 2: Validate Redis Service template with Helm**

Run: `helm template test ./charts/authentik --set redis.enabled=true --dry-run | grep -A 15 "name: redis"`
Expected: Redis Service rendered with correct port and selector

- [ ] **Step 3: Commit Redis Service template**

```bash
git add charts/authentik/templates/redis-service.yaml
git commit -m "feat: add Redis Service template"
```