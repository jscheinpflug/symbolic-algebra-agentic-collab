#!/usr/bin/env bash
set -euo pipefail

./scripts/policy/check-required-files.sh
./scripts/policy/check-schemas.sh
./scripts/policy/check-doc-index.sh
./scripts/policy/check-protocol-tags.sh
./scripts/policy/check-reviewer-policy.sh

if [ "${SKIP_BENCHMARK_POLICY_CHECK:-0}" = "1" ]; then
  echo "Skipping benchmark regression check (SKIP_BENCHMARK_POLICY_CHECK=1)."
else
  ./scripts/policy/check-bench-regressions.sh
fi

./scripts/policy/check-no-partials.sh
./scripts/policy/check-no-string.sh
./scripts/policy/check-test-layout.sh
./scripts/policy/check-property-tests.sh
./scripts/policy/check-rule-freshness.sh
./scripts/policy/check-policy-coverage.sh
./scripts/policy/check-tdd-phase.sh
./scripts/policy/test-check-tdd-phase-fixtures.sh
./scripts/policy/check-dead-rules.sh

echo "All policy checks passed."
