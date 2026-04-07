# Authentik Multi-Architecture Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure Authentik Helm chart supports deployment on both AMD64 and ARM64 architectures.

**Architecture:** Use multi-architecture container images that automatically resolve to the correct platform variant at runtime.

**Tech Stack:** Docker multi-arch manifests, Kubernetes image pulling.

---

### Task 1: Verify Multi-Architecture Support

**Files:**
- Verify: Container images in `charts/authentik/values.yaml`

- [ ] **Step 1: Check Authentik server image multi-arch support**

Run: `docker manifest inspect ghcr.io/goauthentik/server:2026.2.2`
Expected: Manifest list with amd64 and arm64 variants

- [ ] **Step 2: Check PostgreSQL image multi-arch support**

Run: `docker manifest inspect postgres:15`
Expected: Manifest list with multiple platforms

- [ ] **Step 3: Check Redis image multi-arch support**

Run: `docker manifest inspect redis:7-alpine`
Expected: Manifest list with multiple platforms

- [ ] **Step 4: Update README with multi-architecture support note**

Add to `README.md`:

```markdown
## Architecture Support

This chart supports deployment on both AMD64 and ARM64 architectures. The container images automatically resolve to the appropriate platform variant based on the target node architecture.
```

- [ ] **Step 5: Commit documentation update**

```bash
git add README.md
git commit -m "docs: document multi-architecture support for amd64 and arm64"
```