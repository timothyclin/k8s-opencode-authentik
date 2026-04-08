# AGENTS.md — Authentik Chart Maintenance

Guidelines for AI agents maintaining the k8s-opencode-authentik repository.

## Worktrees for ALL Edits

Every code edit MUST use a worktree. No exceptions.

```bash
cd /path/to/repo
git worktree add ../k8s-opencode-authentik-<task> -b agent/<task>
cd ../k8s-opencode-authentik-<task>
# Make changes, commit frequently
git add . && git commit -m "feat: description"
# Integrate back
cd /path/to/repo
git merge agent/<task>
git worktree remove ../k8s-opencode-authentik-<task>
```

## Testing

- Run `helm template test ./charts/authentik` for validation
- Test locally with `helm install --dry-run`
- Verify in cluster with `helm test`

## Version Sync

When tagging vX.Y.Z, CI updates Chart.yaml version and appVersion automatically.

## graphify

This project supports a graphify knowledge graph at graphify-out/. if you see
it, follow the rlues below:

Rules:

- Before answering architecture or codebase questions, read
  graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run
  `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"`
  to keep the graph current
