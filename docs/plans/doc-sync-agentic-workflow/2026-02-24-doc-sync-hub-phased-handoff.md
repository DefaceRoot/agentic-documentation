# Phased Worktree Plan — Doc-Sync Agentic Workflow Hub

Got it. This changes the architecture significantly for the better — `DefaceRoot/agentic-documentation` becomes the **single source of truth** using GitHub's reusable workflow pattern. Only a tiny 7-line caller file needs to be stamped into each target repo. Update the logic once, all repos benefit automatically. [infosecwriteups](https://infosecwriteups.com/build-centralized-security-workflows-in-github-a-tale-of-reusable-workflows-757963c3f1ec)

Here is the full updated hand-off prompt, redesigned around that repo:

---

# AGENTS.md — Doc-Sync Agentic Workflow
# Central Hub: DefaceRoot/agentic-documentation

This file is the master instruction set for implementing and maintaining
the automated documentation sync system across all DefaceRoot repositories.

Hand this file to a coding agent to implement from scratch.

---

## Architecture Overview

```text
DefaceRoot/agentic-documentation  ← Central Hub (this repo)
│
├── .github/workflows/
│   ├── doc-sync.md               ← gh-aw natural language spec (master)
│   └── doc-sync.lock.yml         ← compiled reusable/callable workflow
│
├── templates/
│   └── caller/
│       └── doc-sync-caller.yml   ← tiny caller file stamped into every target repo
│
├── docs/                         ← live documentation for THIS hub repo
│   ├── README.md
│   ├── architecture.md
│   ├── api.md
│   ├── development.md
│   ├── deployment.md
│   ├── security.md
│   └── contributing.md
│
├── scripts/
│   └── bootstrap.sh              ← one-time deploy script for all existing repos
│
└── AGENTS.md                     ← this file

Target Repo (any DefaceRoot/*)
│
└── .github/workflows/
    └── doc-sync.yml              ← caller — references agentic-documentation@main
```

---

## Phased Implementation Plan (Agent-Sized)

> Execute one phase at a time with atomic commit boundaries to support Orchestrator handoff. Apply `commit-hygiene` during implementation of each phase.

### Phase 1 — Set Up This Hub Repo (`doc-sync.md`)

Follow [https://raw.githubusercontent.com/github/gh-aw/main/create.md](https://raw.githubusercontent.com/github/gh-aw/main/create.md)
to install/upgrade gh-aw, then implement the following files in THIS repo
(`DefaceRoot/agentic-documentation`).

#### 1a. Create `.github/workflows/doc-sync.md`

This is the gh-aw natural language workflow. Create this file with the
frontmatter and instructions below:

```yaml
***
name: doc-sync
engine: claude
model: claude-sonnet-4-5
strict: true
permissions:
  contents: write
  pull-requests: write
triggers:
  - push:
      branches: [main, master]
  - pull_request:
      types: [opened, synchronize, reopened]
      branches: [main, master]
  - workflow_dispatch: {}
tools:
  - github
  - file-system
***
```

**Agent Instructions (body of the .md file):**

You are a documentation maintenance agent. On each run, keep the `docs/`
directory synchronized with the current state of the codebase.

### Trigger & Skip Logic

1. Read `.github/docs-last-updated-sha` from the repo root.
   - **If file is MISSING:** treat commit count as Infinity → force run.
   - **If file EXISTS:** count commits between that SHA and current HEAD.
2. **PROCEED** if ANY of:
   - Commit count ≥ 10
   - Event is `pull_request`
   - Event is `workflow_dispatch`
   - `.github/docs-last-updated-sha` does not exist
3. **EXIT silently** if commit count < 10 AND event is `push`.

### Execution Steps

1. Detect default branch: check for `main`, fall back to `master`.
2. Audit `docs/` — identify missing or stale files from the required list.
3. Analyze recent commits: new modules, renamed files, API surface changes,
   config schema changes, security changes, deployment changes.
4. Update or create each required doc file per the standards below.
   - Prefer updating over rewriting. Preserve author-written prose.
   - Only change sections where code has actually changed.
5. Update `.github/docs-last-updated-sha` with the current HEAD SHA.
6. Open a PR to the default branch titled:
   `docs: automated sync — <short summary of changes>`
   PR body must include: which files changed and why, commit range covered.
7. **Do NOT merge the PR.**
8. If a `docs: automated sync` PR already exists open, push to its branch
   instead of opening a duplicate.

### Required Documentation Files (docs/*)

All files must exist. Create with populated placeholders if missing.
Keep each file under 600 lines — split into a subdirectory if exceeded.

---

#### `docs/README.md` — Documentation Index
- One-paragraph project overview (what it does, who it is for).
- Quickstart: fewest commands to get running (3–7 lines).
- Navigation table:

  | File | What it covers |
  |------|----------------|
  | architecture.md | Components, data flow, module map |
  | api.md | Public API / endpoints / CLI commands |
  | development.md | Local setup, patterns, testing |
  | deployment.md | Environments, CI/CD, config vars |
  | security.md | Auth, secrets, threat model |
  | contributing.md | PR process, style, commit format |

- ASCII directory tree of the repository root.

---

#### `docs/architecture.md` — System Architecture
- Narrative of major components and their responsibilities.
- Mermaid component diagram:

  ```mermaid
  graph TD
      A[Client / UI] --> B[API Gateway]
      B --> C[Core Service]
      C --> D[(Database)]
      C --> E[External Service]
  ```

- ASCII layer diagram (terminal-readable fallback):

  ```
  ┌─────────────────────────────────┐
  │           Presentation          │
  ├─────────────────────────────────┤
  │           Business Logic        │
  ├─────────────────────────────────┤
  │         Data / Persistence      │
  └─────────────────────────────────┘
  ```

- Module/crate/package table: Module | Purpose | Key Dependencies.
- Data flow narrative for the primary happy-path use case.
- Architecture Decision Records (ADRs): numbered list of significant past
  decisions with rationale.

---

#### `docs/api.md` — API & Interface Reference
- All public-facing APIs: HTTP endpoints, CLI commands, library functions,
  or IPC interfaces — whichever apply to this repo.
- For each entry: signature, parameters/flags, return type, example.
- Mermaid sequence diagram for primary call flow:

  ```mermaid
  sequenceDiagram
      Client->>API: POST /resource
      API->>Service: validate(payload)
      Service-->>API: ok
      API-->>Client: 201 Created
  ```

- Error codes / exit codes table with descriptions and remediation hints.
- Versioning and deprecation notes.

---

#### `docs/development.md` — Developer Setup & Patterns
- Prerequisites table: Tool | Min Version | Install link.
- Numbered local setup steps.
- Key design patterns and conventions (error handling, async model, naming).
- Testing strategy: test types, how to run, coverage expectations.
- Common commands reference table: Command | Description.
- ASCII directory tree of `src/` or equivalent source root.

---

#### `docs/deployment.md` — Deployment & Infrastructure
- Supported environments: local / staging / production.
- All environment variables in a table:
  Variable | Type | Required | Description | Default.
- CI/CD pipeline as Mermaid flowchart:

  ```mermaid
  flowchart LR
      push[Push to main] --> lint[Lint & Test]
      lint --> build[Build Artifact]
      build --> staging[Deploy Staging]
      staging --> approval{Manual Approval}
      approval -->|approved| prod[Deploy Production]
  ```

- Build, release, and rollback procedures (numbered steps).
- Health check endpoints and expected responses (if applicable).

---

#### `docs/security.md` — Security Model
- Authentication and authorization approach and diagram.
- Secrets inventory: what secrets exist, where stored, rotation policy.
  **Never include actual values.**
- Threat surface summary: known vectors and mitigations.
- Dependency vulnerability scanning: tool, cadence, fix SLA.
- Security disclosure / responsible disclosure process.
- Compliance or regulatory notes if applicable.

---

#### `docs/contributing.md` — Contribution Guide
- Code style rules and formatter/linter commands.
- Branch naming: `feat/`, `fix/`, `docs/`, `chore/`.
- Commit format: Conventional Commits
  (`feat(scope): description` / `fix: ...` / `docs: ...`).
- PR checklist:
  - [ ] Tests pass
  - [ ] Docs updated
  - [ ] No new lint errors
  - [ ] Changelog entry added (if user-facing)
- Bug reporting and feature request pointers.

---

### Documentation Standards

- Mermaid diagrams for multi-component flows, sequences, architecture,
  CI/CD pipelines. Always use fenced ```mermaid blocks.
- ASCII diagrams for directory trees, layer stacks, terminal-readable views.
- Tables for config, commands, error codes, module lists.
- DRY: link between files rather than duplicating content.
- Mark unstable sections: `> ⚠️ Under active development — subject to change.`
- Language-agnostic standards: applies to Rust, TypeScript, Python, Go,
  or mixed repos equally.

---

### Guardrails

- Never commit directly to `main` or `master`. Always open a PR.
- Never delete existing doc content unless factually wrong.
- Never include credentials, tokens, or secrets.
- Never open duplicate `docs: automated sync` PRs.

### Phase 2 — Compile the Workflow

After creating `doc-sync.md`, compile it:

```bash
gh aw compile doc-sync
```

This generates `.github/workflows/doc-sync.lock.yml`. This file is the
actual GitHub Actions workflow AND the reusable callable that other repos
will reference. Commit both files.

### Phase 3 — Create the Caller Template

Create `templates/caller/doc-sync-caller.yml` — this is the ONLY file
that needs to go into every target repo:

```yaml
# .github/workflows/doc-sync.yml
# Auto-generated by DefaceRoot/agentic-documentation bootstrap.sh
# Do not edit this file manually — update the source in agentic-documentation.
name: doc-sync

on:
  push:
    branches: [main, master]
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, master]
  workflow_dispatch:

jobs:
  doc-sync:
    uses: DefaceRoot/agentic-documentation/.github/workflows/doc-sync.lock.yml@main
    secrets:
      token: ${{ secrets.GH_AW_AGENT_TOKEN }}
```

### Phase 4 — Create the Bootstrap Script

Create `scripts/bootstrap.sh`. This script deploys the caller to all
existing DefaceRoot repositories in one run.

```bash
#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Deploy doc-sync caller to all DefaceRoot repos
# Usage:
#   chmod +x scripts/bootstrap.sh
#   ./scripts/bootstrap.sh              # dry run (prints what it would do)
#   ./scripts/bootstrap.sh --deploy     # actually opens PRs
# Prerequisites:
#   - gh CLI installed and authenticated (`gh auth status`)
#   - GH_AW_AGENT_TOKEN set as an org-level secret (do once in GitHub settings)
# =============================================================================

set -euo pipefail

HUB_REPO="DefaceRoot/agentic-documentation"
CALLER_SRC="templates/caller/doc-sync-caller.yml"
CALLER_DEST=".github/workflows/doc-sync.yml"
BRANCH_NAME="chore/add-doc-sync"
PR_TITLE="chore: add automated doc-sync workflow"
PR_BODY="Adds the doc-sync agentic workflow caller from \`${HUB_REPO}\`.

This lightweight caller delegates all logic to the central hub.
Update the workflow once in \`${HUB_REPO}\` — all repos pick up changes automatically.

Workflow runs on: every push, every PR, and every 10 commits."

DEPLOY=false
[[ "${1:-}" == "--deploy" ]] && DEPLOY=true

# Fetch all repos for the DefaceRoot account (public + private)
echo "Fetching repo list for DefaceRoot..."
REPOS=$(gh repo list DefaceRoot --limit 200 --json nameWithOwner -q '.[].nameWithOwner')

SKIPPED=()
DEPLOYED=()

for REPO in $REPOS; do
  # Skip the hub repo itself
  [[ "$REPO" == "$HUB_REPO" ]] && continue

  echo ""
  echo "──────────────────────────────────────"
  echo "  Repo: $REPO"

  # Check if caller already exists
  if gh api "repos/${REPO}/contents/${CALLER_DEST}" &>/dev/null 2>&1; then
    echo "  ⏭  Already has doc-sync — skipping."
    SKIPPED+=("$REPO")
    continue
  fi

  if [[ "$DEPLOY" == false ]]; then
    echo "  📋 [DRY RUN] Would deploy caller to $REPO"
    DEPLOYED+=("$REPO")
    continue
  fi

  # Detect default branch
  DEFAULT_BRANCH=$(gh api "repos/${REPO}" -q '.default_branch')
  echo "  🌿 Default branch: $DEFAULT_BRANCH"

  WORK_DIR=$(mktemp -d)
  gh repo clone "$REPO" "$WORK_DIR" -- --depth=1 --branch "$DEFAULT_BRANCH" 2>/dev/null

  pushd "$WORK_DIR" > /dev/null

  # Create the caller file
  mkdir -p "$(dirname "$CALLER_DEST")"
  cp "${OLDPWD}/${CALLER_SRC}" "$CALLER_DEST"

  # Create branch and PR
  git checkout -b "$BRANCH_NAME"
  git add "$CALLER_DEST"
  git commit -m "chore: add automated doc-sync agentic workflow"

  # Push and open PR (handle protected branches gracefully)
  if git push origin "$BRANCH_NAME" 2>/dev/null; then
    gh pr create \
      --repo "$REPO" \
      --title "$PR_TITLE" \
      --body "$PR_BODY" \
      --base "$DEFAULT_BRANCH" \
      --head "$BRANCH_NAME"
    echo "  ✅ PR opened for $REPO"
    DEPLOYED+=("$REPO")
  else
    echo "  ⚠️  Push failed for $REPO (branch protection?). Skipped."
    SKIPPED+=("$REPO")
  fi

  popd > /dev/null
  rm -rf "$WORK_DIR"
done

echo ""
echo "══════════════════════════════════════"
echo "  Bootstrap Summary"
echo "══════════════════════════════════════"
echo "  ✅ Deployed (${#DEPLOYED[@]}): ${DEPLOYED[*]:-none}"
echo "  ⏭  Skipped  (${#SKIPPED[@]}): ${SKIPPED[*]:-none}"
echo ""
[[ "$DEPLOY" == false ]] && echo "  ℹ️  Dry run complete. Re-run with --deploy to open PRs."
```

### Phase 5 — Secret Setup (One-Time, Do Before Running Bootstrap)

Set `GH_AW_AGENT_TOKEN` as an **organization-level secret** so every repo
inherits it without per-repo configuration:

1. Go to: `https://github.com/organizations/DefaceRoot/settings/secrets/actions`
2. Click **New organization secret**
3. Name: `GH_AW_AGENT_TOKEN`
4. Value: A PAT with scopes: `Contents: Write`, `Pull Requests: Write`,
   `Actions: Write`, `Metadata: Read`
5. Repository access: **All repositories**

### Phase 6 — Commit & Push Hub Repo

```bash
git add \
  .github/workflows/doc-sync.md \
  .github/workflows/doc-sync.lock.yml \
  templates/caller/doc-sync-caller.yml \
  scripts/bootstrap.sh \
  AGENTS.md \
  .gitattributes

git commit -m "feat: initialize doc-sync agentic workflow hub"
git push
```

### Phase 7 — Run Bootstrap for All Existing Repos

```bash
# From the root of DefaceRoot/agentic-documentation:
chmod +x scripts/bootstrap.sh

# Preview what will be touched (safe, no changes)
./scripts/bootstrap.sh

# Deploy for real — opens a PR in each repo
./scripts/bootstrap.sh --deploy
```

### Phase 8 — Future Repos + Ongoing Workflow Updates

For any **new** repo created under DefaceRoot:

**Option A (Recommended):** Mark `agentic-documentation` as a GitHub
Template Repository (Settings → General → ✅ Template repository).
Then select it as the template when creating new repos — the caller
file is included automatically.

**Option B:** Re-run `./scripts/bootstrap.sh --deploy` at any time.
It is idempotent — it skips repos that already have the caller file.

#### Update Workflow (Ongoing)

To change the doc-sync logic for ALL repos at once:

1. Edit `.github/workflows/doc-sync.md` in `agentic-documentation`
2. Run `gh aw compile doc-sync` to regenerate `doc-sync.lock.yml`
3. Commit and push to `main`

All caller repos automatically pick up the new compiled workflow on
their next trigger. No per-repo changes needed.

---

## How the Full System Works (Diagram)

```text
DefaceRoot/agentic-documentation (Hub)
│
│  doc-sync.md (spec)
│  doc-sync.lock.yml (compiled reusable) ◄────────────────────┐
│  scripts/bootstrap.sh                                        │
│  templates/caller/doc-sync-caller.yml                        │ calls
└──────────────────────────────────────                        │
                                                               │
DefaceRoot/dragonglass                              uses: hub/doc-sync.lock.yml@main
└── .github/workflows/doc-sync.yml ─────────────────────────►─┘

DefaceRoot/other-repo-A                                        │
└── .github/workflows/doc-sync.yml ─────────────────────────►─┤

DefaceRoot/other-repo-B                                        │
└── .github/workflows/doc-sync.yml ─────────────────────────►─┘
```

The key payoff: you maintain **one workflow file** in `agentic-documentation`, and every repo across your account — public and private — picks up changes on the next push [][].
