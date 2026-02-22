#!/usr/bin/env bash
set -euo pipefail

python3 scripts/agent/validate-reviewer-policy.py --file .agent-reviewer-policy.json
python3 scripts/agent/validate-reviewer-policy.py --self-test

echo "Reviewer policy check passed."
