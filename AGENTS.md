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

## LLM Installation Security

Guidelines for AI agents assisting with Authentik installation:

### Handling Sensitive Information

- **NEVER** read, store, or transmit passwords, cryptographic keys, tokens, or other secrets
- **NEVER** accept secrets provided directly by users in conversation
- **ALWAYS** generate placeholder files with obvious placeholders like `YOUR_SECRET_HERE`
- **ALWAYS** cue humans to replace placeholders with actual values
- **ALWAYS** instruct humans to delete placeholder files after use

### Placeholder File Creation

When secrets are required:
1. Create a YAML file with placeholder values
2. Clearly comment what each placeholder represents
3. Instruct the human to replace placeholders
4. Reference this file in commands using `-f filename.yaml`

### Example

```yaml
# values-secrets.yaml
authentik:
  secret_key: "YOUR_AUTHENTIK_SECRET_KEY_HERE"  # Generate 50+ character random string
  postgresql:
    password: "YOUR_DATABASE_PASSWORD_HERE"    # Must match PostgreSQL setup
```

Human must replace `YOUR_*_HERE` values before proceeding.

### Validation

After placeholder replacement:
- Verify files exist and placeholders are replaced
- Do not inspect file contents for actual secret values
- Proceed with installation using the updated files
