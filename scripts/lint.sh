#!/usr/bin/env bash
set -euo pipefail

hlint app src test --hint=.hlint.yaml
./scripts/policy/check-no-partials.sh
./scripts/policy/check-no-string.sh
echo "Lint check passed."
