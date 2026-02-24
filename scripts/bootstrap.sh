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
  echo "--------------------------------------"
  echo "  Repo: $REPO"

  # Check if caller already exists
  if gh api "repos/${REPO}/contents/${CALLER_DEST}" &>/dev/null 2>&1; then
    echo "  [SKIP] Already has doc-sync — skipping."
    SKIPPED+=("$REPO")
    continue
  fi

  if [[ "$DEPLOY" == false ]]; then
    echo "  [DRY RUN] Would deploy caller to $REPO"
    DEPLOYED+=("$REPO")
    continue
  fi

  # Detect default branch
  DEFAULT_BRANCH=$(gh api "repos/${REPO}" -q '.default_branch')
  echo "  Default branch: $DEFAULT_BRANCH"

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
    echo "  PR opened for $REPO"
    DEPLOYED+=("$REPO")
  else
    echo "  Push failed for $REPO (branch protection?). Skipped."
    SKIPPED+=("$REPO")
  fi

  popd > /dev/null
  rm -rf "$WORK_DIR"
done

echo ""
echo "======================================"
echo "  Bootstrap Summary"
echo "======================================"
echo "  Deployed (${#DEPLOYED[@]}): ${DEPLOYED[*]:-none}"
echo "  Skipped  (${#SKIPPED[@]}): ${SKIPPED[*]:-none}"
echo ""
[[ "$DEPLOY" == false ]] && echo "  Dry run complete. Re-run with --deploy to open PRs."
