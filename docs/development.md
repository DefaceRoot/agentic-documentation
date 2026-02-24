# Development Guide

## Prerequisites

- `gh` CLI >= 2.0
- `bash`
- `git`
- `opencode` CLI (installed automatically by the workflow; optional locally)

## Local Testing

1. Clone this repository.
2. Authenticate GitHub CLI: `gh auth login`.
3. Export API key: `export OPENCODE_API_KEY="<your-key>"`.
4. Trigger a run:
   ```bash
   gh workflow run .github/workflows/doc-sync-opencode.yml --repo DefaceRoot/agentic-documentation
   ```

## Updating the Doc-Sync Prompt

1. Edit `.github/workflows/doc-sync-prompt.md`.
2. Commit and merge to `main`.
3. On the next trigger in any caller repository, the updated prompt is used automatically.

## Adding a New Workflow Input

1. Edit `.github/workflows/doc-sync-opencode.yml` and define the new input under both `workflow_dispatch.inputs` and `workflow_call.inputs`.
2. Update `templates/caller/doc-sync-caller.yml` if invocation or interface expectations changed.
3. Run `scripts/bootstrap.sh --deploy` to propagate caller updates across existing repositories.
