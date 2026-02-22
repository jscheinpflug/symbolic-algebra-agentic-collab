#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
from pathlib import Path
import os
import sys

signals_dir = Path("artifacts/policy-signals")
if not signals_dir.exists():
    print("No policy signals directory found; skipping dead-rule check.")
    sys.exit(0)

signal_files = sorted(signals_dir.glob("*.json"))
if not signal_files:
    print("No policy signal JSON files found; skipping dead-rule check.")
    sys.exit(0)

latest = signal_files[-1]
data = json.loads(latest.read_text(encoding="utf-8"))
dead_rules = data.get("dead_rules", [])
threshold = int(os.getenv("DEAD_RULE_FAIL_DAYS", "30"))

blocking = []
for item in dead_rules:
    if not isinstance(item, dict):
        continue
    age_days = item.get("age_days", 0)
    rule_id = item.get("rule_id", "unknown-rule")
    if isinstance(age_days, int) and age_days >= threshold:
        blocking.append((rule_id, age_days))

if blocking:
    print(f"Dead-rule check failed (threshold={threshold} days) using {latest}:")
    for rule_id, age_days in blocking:
        print(f"- {rule_id}: {age_days} days")
    sys.exit(1)

print(f"Dead-rule check passed using {latest.name}.")
PY
