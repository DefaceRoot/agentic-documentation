# DefaceRoot Documentation Hub

`DefaceRoot/agentic-documentation` is the central documentation automation hub for the DefaceRoot GitHub organization: it hosts the reusable GitHub Actions workflow, the shared prompt, and deployment tooling that let each spoke repository run `opencode` and keep `docs/` synchronized through automated pull requests.

## Quickstart (add doc-sync to a new repository)

1. Copy `templates/caller/doc-sync-caller.yml` into the target repo as `.github/workflows/doc-sync.yml`.
2. Add repository (or org) secrets: `OPENCODE_API_KEY` and `GH_AW_AGENT_TOKEN`.
3. Trigger the workflow with `workflow_dispatch`, or let the next push/PR run sync automatically.

## Navigation

| File | What it covers |
|------|----------------|
| [architecture.md](./architecture.md) | Hub-and-spoke design, runtime flow, and architecture decisions |
| [api.md](./api.md) | Reusable workflow inputs, required secrets, execution sequence, bootstrap CLI |
| [development.md](./development.md) | Local setup, testing, prompt updates, and workflow evolution |
| [deployment.md](./deployment.md) | Secrets/inputs, CI/CD flow, org-wide rollout, single-repo rollout |
| [security.md](./security.md) | Secret handling, token scopes, branch protection, threat surface |
| [contributing.md](./contributing.md) | Branch/commit conventions, PR checklist, and issue reporting |

## Repository Tree

```text
.
├── .github/
│   ├── aw/
│   │   └── actions-lock.json
│   └── workflows/
│       ├── doc-sync.md              ← gh-aw source prompt (alternative)
│       ├── doc-sync.lock.yml        ← gh-aw compiled workflow
│       ├── doc-sync-opencode.yml    ← reusable workflow (hub)
│       └── doc-sync-prompt.md       ← agent instructions
├── docs/
│   ├── README.md
│   ├── api.md
│   ├── architecture.md
│   ├── contributing.md
│   ├── deployment.md
│   ├── development.md
│   ├── plans/
│   └── security.md
├── scripts/
│   └── bootstrap.sh                 ← deploy to all repos
├── templates/
│   └── caller/
│       └── doc-sync-caller.yml      ← stamp into target repos
├── opencode.json                    ← Z.AI provider config
└── README.md
```
