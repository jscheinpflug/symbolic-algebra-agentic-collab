#!/usr/bin/env bash
set -euo pipefail

./scripts/policy/check-required-files.sh
./scripts/policy/check-schemas.sh
./scripts/policy/check-doc-index.sh
./scripts/policy/check-protocol-tags.sh
./scripts/policy/check-reviewer-policy.sh
./scripts/policy/check-bench-regressions.sh
./scripts/policy/check-no-partials.sh
./scripts/policy/check-no-string.sh
./scripts/policy/check-rule-freshness.sh
./scripts/policy/check-policy-coverage.sh
./scripts/policy/check-dead-rules.sh

echo "All policy checks passed."
