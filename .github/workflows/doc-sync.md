---
name: doc-sync
engine:
  id: codex
  model: glm-5
  env:
    OPENAI_BASE_URL: https://api.z.ai/api/coding/paas/v4
  args:
    - -c
    - 'model_provider="zai"'
    - -c
    - 'model_providers.zai.name="Z.AI"'
    - -c
    - 'model_providers.zai.base_url="https://api.z.ai/api/coding/paas/v4"'
    - -c
    - 'model_providers.zai.env_key="CODEX_API_KEY"'
    - -c
    - 'model_providers.zai.wire_api="responses"'
network:
  allowed:
    - defaults
    - node
    - api.z.ai
strict: false
permissions:
  contents: read
  actions: read
  issues: read
  pull-requests: read
on:
  push:
    branches: [main, master]
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, master]
  workflow_dispatch:
  workflow_call:
    secrets:
      token:
        required: true
tools:
  github:
  edit:
  bash: true
safe-outputs:
  create-pull-request:
    draft: false
---

You are a documentation maintenance agent. On each run, keep the `docs/`
directory synchronized with the current state of the codebase.

### Trigger & Skip Logic

1. Read `.github/docs-last-updated-sha` from the repo root.
   - **If file is MISSING:** treat commit count as Infinity — force run.
   - **If file EXISTS:** count commits between that SHA and current HEAD.
2. **PROCEED** if ANY of:
   - Commit count >= 10
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
- Quickstart: fewest commands to get running (3-7 lines).
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
  +-------------------------------+
  |           Presentation        |
  +-------------------------------+
  |         Business Logic        |
  +-------------------------------+
  |       Data / Persistence      |
  +-------------------------------+
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
- Mark unstable sections: `> WARNING: Under active development — subject to change.`
- Language-agnostic standards: applies to Rust, TypeScript, Python, Go,
  or mixed repos equally.

---

### Guardrails

- Never commit directly to `main` or `master`. Always open a PR.
- Never delete existing doc content unless factually wrong.
- Never include credentials, tokens, or secrets.
- Never open duplicate `docs: automated sync` PRs.
