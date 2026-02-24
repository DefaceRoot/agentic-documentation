# Contributing

## Branch Naming

Use one of the approved prefixes:
- `feat/`
- `fix/`
- `docs/`
- `chore/`

## Commit Format

Use Conventional Commits (for example: `docs: update doc-sync deployment guide`).

## Updating Doc-Sync Logic

To change system behavior, edit one of these hub files:
- `.github/workflows/doc-sync-prompt.md` (agent behavior/policy)
- `.github/workflows/doc-sync-opencode.yml` (workflow/runtime behavior)

## Pull Request Checklist

- [ ] Workflow YAML is valid
- [ ] Prompt changes tested via `workflow_dispatch`
- [ ] Caller template updated if workflow inputs changed

## Reporting Issues

Report bugs and feature requests through GitHub Issues in `DefaceRoot/agentic-documentation`.
