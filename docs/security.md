# Security

## Secrets Used

- `OPENCODE_API_KEY`: Z.AI/OpenAI-compatible API key used by the `opencode` harness.
- `GH_AW_AGENT_TOKEN`: GitHub Personal Access Token used for committing docs updates and opening pull requests.

## Secret Scope

Store secrets at either:
- **Repository level** for isolated control, or
- **Organization level** for centralized management across DefaceRoot repos.

## Rotation

Rotate secrets from **GitHub Settings → Secrets and variables → Actions** on a defined cadence or immediately after suspected exposure.

## Minimum `GH_AW_AGENT_TOKEN` Scopes

- `contents: write`
- `pull-requests: write`
- `metadata: read`

## Threat Surface and Guardrails

- The automation PR is constrained to documentation outputs (`docs/**`) plus `.github/docs-last-updated-sha`.
- It cannot modify workflow files as part of its documented change set.
- It cannot run arbitrary code beyond the centrally managed prompt-driven doc-sync execution path.

## Prompt Supply Chain

The doc-sync prompt is fetched from the hub repo `main` branch. Protect `main` with branch protection rules (required reviews, status checks, and restricted pushes) to reduce prompt tampering risk.

## Secret Hygiene

Never commit actual secret values to source control, PR descriptions, logs, or issue comments.
