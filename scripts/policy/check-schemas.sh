#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
from pathlib import Path
import sys

schema_dir = Path("schemas")
if not schema_dir.exists():
    print("schemas/ directory is missing")
    sys.exit(1)

schema_files = sorted(schema_dir.glob("*.json"))
if not schema_files:
    print("No schema files found in schemas/")
    sys.exit(1)

for path in schema_files:
    try:
        with path.open("r", encoding="utf-8") as handle:
            json.load(handle)
    except Exception as exc:  # noqa: BLE001
        print(f"Invalid JSON in {path}: {exc}")
        sys.exit(1)

print(f"Schema syntax check passed for {len(schema_files)} files.")
PY
