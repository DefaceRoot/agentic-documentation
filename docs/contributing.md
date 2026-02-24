# Contributing

## Code Style Rules

### Shell Scripts (`.sh`)

| Rule | Example |
|------|---------|
| Use `#!/usr/bin/env bash` | First line of script |
| Enable strict mode | `set -euo pipefail` |
| Quote variables | `"${VAR}"` not `$VAR` |
| Use `[[ ]]` for tests | `[[ -f "$file" ]]` |
| Use `printf` over `echo` | `printf '%s\n' "$msg"` |

### YAML (workflows)

| Rule | Example |
|------|---------|
| 2-space indentation | Consistent formatting |
| Quote strings with special chars | `branch: "docs/sync"` |
| Document inputs | Add `description:` for each |

### Markdown (docs)

| Rule | Example |
|------|---------|
| ATX headings | `## Section` |
| Fenced code blocks | ` ```bash ` |
| Tables for structured data | Use pipe tables |

## Branch Naming

Use one of the approved prefixes:

| Prefix | Purpose |
|--------|---------|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `docs/` | Documentation only |
| `chore/` | Maintenance, tooling |

Example: `feat/add-custom-model-support`

## Commit Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance |
| `refactor` | Code refactoring |
| `test` | Adding/updating tests |

### Examples

```
docs: update doc-sync deployment guide
fix(opencode-workflow): handle authentication errors
feat: add custom model input support
chore: update bootstrap.sh for new repos
```

## Updating Doc-Sync Logic

To change system behavior, edit one of these hub files:

| File | Changes |
|------|---------|
| `.github/workflows/doc-sync-prompt.md` | Agent behavior/policy |
| `.github/workflows/doc-sync-opencode.yml` | Workflow/runtime behavior |
| `templates/caller/doc-sync-caller.yml` | Caller interface |

## Pull Request Checklist

Before submitting a PR:

- [ ] **Workflow YAML is valid** — no syntax errors
- [ ] **Prompt changes tested** — via `workflow_dispatch` on a test repo
- [ ] **Caller template updated** — if workflow inputs changed
- [ ] **Documentation updated** — docs reflect code changes
- [ ] **No secrets in code** — credentials, tokens, keys removed
- [ ] **Commit messages follow Conventional Commits**
- [ ] **Branch name follows conventions**

### PR Title Format

Match commit format:
```
feat(scope): description
fix: description
docs: description
```

## Reporting Issues

### Bug Reports

Report bugs through GitHub Issues in `DefaceRoot/agentic-documentation`.

Include:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Workflow run logs (redact secrets)
5. Repository and branch affected

### Feature Requests

1. Check existing issues for duplicates
2. Describe the use case
3. Explain the proposed solution
4. Note any alternatives considered

### Security Issues

See [security.md](./security.md) for the security disclosure process. **Do not** open public issues for security vulnerabilities.
