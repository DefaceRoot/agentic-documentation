# Development Guide

## Prerequisites

| Tool | Min Version | Install Link |
|------|-------------|--------------|
| `gh` CLI | 2.0 | https://cli.github.com |
| `bash` | 4.0 | (system default) |
| `git` | 2.0 | https://git-scm.com |
| `opencode` CLI | latest | https://opencode.ai (auto-installed) |

## Local Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/DefaceRoot/agentic-documentation.git
   cd agentic-documentation
   ```

2. Authenticate GitHub CLI:
   ```bash
   gh auth login
   ```

3. Set API key for local testing:
   ```bash
   export OPENCODE_API_KEY="<your-key>"
   ```

4. (Optional) Install opencode locally:
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

## Local Testing

### Trigger Workflow via GitHub CLI

```bash
gh workflow run .github/workflows/doc-sync-opencode.yml --repo DefaceRoot/agentic-documentation
```

### Run opencode Locally

```bash
export OPENAI_API_KEY="$OPENCODE_API_KEY"
export OPENAI_BASE_URL="https://api.z.ai/api/coding/paas/v4"
export MODEL="glm-5"

opencode run --model zai/glm-5 "$(cat .github/workflows/doc-sync-prompt.md)"
```

### Dry-Run Bootstrap

```bash
./scripts/bootstrap.sh
```

## Key Design Patterns

### Reusable Workflow Pattern

The hub exposes a single reusable workflow (`doc-sync-opencode.yml`) that spoke repos call via `uses:` with `secrets: inherit`. This centralizes all logic in one place.

### Prompt-as-Code

The doc-sync prompt (`doc-sync-prompt.md`) is versioned alongside the workflow. Changes to the prompt are applied atomically with workflow changes.

### SHA-Based Change Detection

The `.github/docs-last-updated-sha` file tracks the last commit where docs were synced. The workflow reads this file to determine if sync should run.

### Fallback Authentication

The workflow supports multiple secret names for flexibility:
- `secrets.api_key` (passed from caller)
- `secrets.OPENCODE_API_KEY` (repo/org level)
- `secrets.OPENAI_API_KEY` (fallback)

## Testing Strategy

| Test Type | How to Run | Coverage |
|-----------|------------|----------|
| Workflow trigger | `gh workflow run ...` | End-to-end |
| Bootstrap dry-run | `./scripts/bootstrap.sh` | Repo discovery |
| Local opencode | `opencode run ...` | Agent behavior |

### Manual Testing Checklist

- [ ] Workflow completes without errors
- [ ] Docs are generated/updated correctly
- [ ] SHA file is written
- [ ] PR is created with correct branch/title
- [ ] No secrets leaked in logs

## Common Commands

| Command | Description |
|---------|-------------|
| `gh workflow run .github/workflows/doc-sync-opencode.yml` | Trigger workflow |
| `gh run list --workflow=doc-sync-opencode.yml` | List recent runs |
| `gh run view` | View latest run |
| `./scripts/bootstrap.sh` | Dry-run bootstrap |
| `./scripts/bootstrap.sh --deploy` | Deploy to all repos |
| `opencode run --model zai/glm-5 "prompt"` | Run opencode locally |

## Updating the Doc-Sync Prompt

1. Edit `.github/workflows/doc-sync-prompt.md`.
2. Test locally or via `workflow_dispatch`.
3. Commit and merge to `main`.
4. On the next trigger in any caller repository, the updated prompt is used automatically.

## Adding a New Workflow Input

1. Edit `.github/workflows/doc-sync-opencode.yml` and define the new input under both `workflow_dispatch.inputs` and `workflow_call.inputs`.
2. Update `templates/caller/doc-sync-caller.yml` if invocation or interface expectations changed.
3. Run `scripts/bootstrap.sh --deploy` to propagate caller updates across existing repositories.
