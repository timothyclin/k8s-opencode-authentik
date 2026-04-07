# AGENTS.md — Authentik Chart Maintenance

Guidelines for AI agents maintaining the k8s-opencode-authentik repository.

## Worktrees for ALL Edits

Every code edit MUST use a worktree. No exceptions.

```bash
cd /path/to/repo
git worktree add ../authentik-<task> -b agent/<task>
cd ../authentik-<task>
# Make changes, commit frequently
git add . && git commit -m "feat: description"
# Integrate back
cd /path/to/repo
git merge agent/<task>
git worktree remove ../authentik-<task>
```

## Testing

- Run `helm template test ./charts/authentik` for validation
- Test locally with `helm install --dry-run`
- Verify in cluster with `helm test`

## Version Sync

When tagging vX.Y.Z, CI updates Chart.yaml version and appVersion automatically.
