#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import sys

catalog_path = Path("docs/policy/rules-catalog.md")
if not catalog_path.exists():
    print("Missing docs/policy/rules-catalog.md")
    sys.exit(1)

required_rule_ids = {
    "RULE-001",
    "RULE-002",
    "RULE-003",
    "RULE-004",
    "RULE-005",
    "RULE-006",
}

required_tags = {
    "build",
    "tests",
    "format",
    "lint",
    "policy-schema",
    "policy-docs",
    "review-findings",
    "rule-freshness",
}

rule_ids = set()
coverage_tags = set()

for line in catalog_path.read_text(encoding="utf-8").splitlines():
    if not line.startswith("| RULE-"):
        continue
    parts = [p.strip() for p in line.strip().strip("|").split("|")]
    if len(parts) < 7:
        print(f"Malformed rule row: {line}")
        sys.exit(1)
    rule_id = parts[0]
    tags = [tag.strip() for tag in parts[3].split(",") if tag.strip()]
    rule_ids.add(rule_id)
    coverage_tags.update(tags)

missing_rules = sorted(required_rule_ids - rule_ids)
missing_tags = sorted(required_tags - coverage_tags)

if missing_rules:
    print("Missing required rule IDs in rules catalog:")
    for rule_id in missing_rules:
        print(f"- {rule_id}")
    sys.exit(1)

if missing_tags:
    print("Missing required coverage tags in rules catalog:")
    for tag in missing_tags:
        print(f"- {tag}")
    sys.exit(1)

print("Policy coverage check passed.")
PY
