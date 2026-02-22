#!/usr/bin/env bash
set -euo pipefail

required_paths=(
  "AGENTS.md"
  "README.md"
  "docs/index.md"
  "docs/architecture/layers.md"
  "docs/domains/agentic-loop.md"
  "docs/domains/logging.md"
  "docs/domains/safety.md"
  "docs/policy/rules-catalog.md"
  "docs/policy/changelog.md"
  "docs/quality/scorecard.md"
  "schemas/agent-task.schema.json"
  "schemas/review-artifact.schema.json"
  "schemas/decision-packet.schema.json"
  "schemas/policy-signal.schema.json"
  "schemas/policy-change-proposal.schema.json"
  ".github/ISSUE_TEMPLATE/agent_task.yml"
  ".github/pull_request_template.md"
  ".github/workflows/ci.yml"
  ".github/workflows/agent-loop.yml"
  ".github/workflows/trusted-agent-review.yml"
  ".github/workflows/policy-daily.yml"
  "scripts/policy/check-no-partials.sh"
  "scripts/policy/check-no-string.sh"
  "scripts/policy/check-rule-freshness.sh"
  "scripts/policy/check-policy-coverage.sh"
  "scripts/policy/check-dead-rules.sh"
  "scripts/policy/generate-daily-policy-proposal.py"
  "scripts/policy/validate-policy-artifact.py"
  "scripts/agent/run-review.py"
  "scripts/agent/aggregate-reviews.py"
  "artifacts/policy-signals/.gitkeep"
  "artifacts/policy-proposals/.gitkeep"
)

missing=0
for path in "${required_paths[@]}"; do
  if [ ! -f "$path" ]; then
    echo "Missing required file: $path"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "Required file check passed."
