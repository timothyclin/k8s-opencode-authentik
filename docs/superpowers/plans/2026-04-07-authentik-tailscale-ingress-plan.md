# Authentik Tailscale Ingress Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Tailscale ingress support to the Authentik Helm chart for secure tailnet access.

**Architecture:** Create a Kubernetes Ingress resource that uses Tailscale operator's ingressClassName to proxy HTTPS traffic from the tailnet to the Authentik service.

**Tech Stack:** Kubernetes Ingress API, Helm templating, Tailscale operator.

---

### Task 1: Create Ingress Template

**Files:**
- Create: `charts/authentik/templates/ingress.yaml`

- [ ] **Step 1: Create the ingress.yaml template file with conditional ingress creation**

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "authentik.fullname" . }}-ingress
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: {{ include "authentik.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    helm.sh/chart: {{ include "authentik.chart" . }}
  annotations:
    tailscale.com/tags: "{{ .Values.ingress.tailscale.proxyTag }}"
spec:
  ingressClassName: tailscale
  tls:
  - hosts:
    - {{ .Values.ingress.hostname }}
  rules:
  - host: {{ .Values.ingress.hostname }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ include "authentik.fullname" . }}-authentik
            port:
              number: 443
{{- end }}
```

- [ ] **Step 2: Validate template syntax with Helm**

Run: `helm template test ./charts/authentik --dry-run`
Expected: Valid YAML output without errors

- [ ] **Step 3: Test ingress creation with default values**

Run: `helm template test ./charts/authentik --set ingress.enabled=true`
Expected: Ingress resource rendered with correct name, annotations, and backend service

- [ ] **Step 4: Commit the ingress template**

```bash
git add charts/authentik/templates/ingress.yaml
git commit -m "feat: add Tailscale ingress template for Authentik"
```