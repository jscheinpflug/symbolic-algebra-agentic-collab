#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from datetime import date
from pathlib import Path
import sys

catalog_path = Path("docs/policy/rules-catalog.md")
if not catalog_path.exists():
    print("Missing docs/policy/rules-catalog.md")
    sys.exit(1)

rows = []
for line in catalog_path.read_text(encoding="utf-8").splitlines():
    if line.startswith("| RULE-"):
        parts = [p.strip() for p in line.strip().strip("|").split("|")]
        rows.append(parts)

if not rows:
    print("No rule rows found in docs/policy/rules-catalog.md")
    sys.exit(1)

today = date.today()
errors = []
stale = []

for parts in rows:
    if len(parts) < 7:
        errors.append(f"Malformed rule row: {' | '.join(parts)}")
        continue

    rule_id = parts[0]
    last_reviewed_raw = parts[4]
    freshness_raw = parts[5]

    try:
        last_reviewed = date.fromisoformat(last_reviewed_raw)
    except ValueError:
        errors.append(f"{rule_id}: invalid last_reviewed date '{last_reviewed_raw}'")
        continue

    try:
        freshness_days = int(freshness_raw)
    except ValueError:
        errors.append(f"{rule_id}: invalid freshness_sla_days '{freshness_raw}'")
        continue

    age_days = (today - last_reviewed).days
    if age_days > freshness_days:
        stale.append((rule_id, age_days, freshness_days))

if errors:
    print("Rule freshness check failed due to malformed rows:")
    for item in errors:
        print(f"- {item}")
    sys.exit(1)

if stale:
    print("Rule freshness SLA exceeded:")
    for rule_id, age_days, freshness_days in stale:
        print(f"- {rule_id}: age={age_days} days, SLA={freshness_days} days")
    sys.exit(1)

print(f"Rule freshness check passed for {len(rows)} rules.")
PY
