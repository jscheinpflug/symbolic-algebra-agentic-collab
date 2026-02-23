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
  "docs/domains/testing.md"
  "docs/domains/tdd-phases.md"
  "docs/policy/rules-catalog.md"
  "docs/policy/changelog.md"
  "docs/quality/scorecard.md"
  ".agent-reviewer-policy.json"
  "schemas/agent-task.schema.json"
  "schemas/review-artifact.schema.json"
  "schemas/decision-packet.schema.json"
  "schemas/policy-signal.schema.json"
  "schemas/policy-change-proposal.schema.json"
  "schemas/tdd-phase.schema.json"
  ".github/ISSUE_TEMPLATE/agent_task.yml"
  ".github/pull_request_template.md"
  ".github/workflows/ci.yml"
  ".github/workflows/agent-loop.yml"
  ".github/workflows/trusted-agent-review.yml"
  ".github/workflows/trusted-review-dispatch.yml"
  ".github/workflows/policy-daily.yml"
  "scripts/agent/validate-reviewer-policy.py"
  "scripts/policy/check-reviewer-policy.sh"
  "scripts/policy/check-bench-regressions.sh"
  "scripts/policy/check-no-partials.sh"
  "scripts/policy/check-no-string.sh"
  "scripts/policy/check-test-layout.sh"
  "scripts/policy/check-property-tests.sh"
  "scripts/policy/check-rule-freshness.sh"
  "scripts/policy/check-policy-coverage.sh"
  "scripts/policy/check-tdd-phase.sh"
  "scripts/policy/test-check-tdd-phase-fixtures.sh"
  "scripts/policy/check-dead-rules.sh"
  "scripts/bench/run-benchmarks.sh"
  "scripts/bench/check-regressions.py"
  "scripts/bench/check-cost-sanity.py"
  "scripts/policy/generate-daily-policy-proposal.py"
  "scripts/policy/validate-policy-artifact.py"
  "scripts/agent/run-review.py"
  "scripts/agent/aggregate-reviews.py"
  "bench/Main.hs"
  "bench/baseline/workflow-benchmarks.json"
  "artifacts/policy-signals/.gitkeep"
  "artifacts/policy-proposals/.gitkeep"
  "artifacts/tdd/.gitkeep"
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
