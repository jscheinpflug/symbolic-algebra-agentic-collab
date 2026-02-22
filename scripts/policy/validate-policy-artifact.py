#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


def validate_signal(data: dict) -> int:
    required_top = {"date", "window_hours", "ci", "reviews", "dead_rules"}
    missing = required_top - data.keys()
    if missing:
        return fail(f"Signal artifact missing keys: {sorted(missing)}")

    ci = data["ci"]
    if not isinstance(ci, dict):
        return fail("Signal artifact key 'ci' must be an object.")
    for key in ["failed_runs", "failing_checks", "flaky_checks"]:
        if key not in ci:
            return fail(f"Signal artifact ci missing key: {key}")

    reviews = data["reviews"]
    if not isinstance(reviews, dict):
        return fail("Signal artifact key 'reviews' must be an object.")
    for key in ["changes_requested", "recurring_findings"]:
        if key not in reviews:
            return fail(f"Signal artifact reviews missing key: {key}")

    if not isinstance(data["dead_rules"], list):
        return fail("Signal artifact key 'dead_rules' must be a list.")

    return 0


def validate_proposal(data: dict) -> int:
    required_top = {"date", "source_signal_file", "proposals"}
    missing = required_top - data.keys()
    if missing:
        return fail(f"Proposal artifact missing keys: {sorted(missing)}")

    proposals = data["proposals"]
    if not isinstance(proposals, list):
        return fail("Proposal artifact key 'proposals' must be a list.")

    required_fields = {
        "id",
        "target",
        "severity",
        "change",
        "evidence",
        "risk",
        "rollback_condition",
    }
    for index, proposal in enumerate(proposals):
        if not isinstance(proposal, dict):
            return fail(f"Proposal item at index {index} must be an object.")
        missing_fields = required_fields - proposal.keys()
        if missing_fields:
            return fail(
                f"Proposal item at index {index} missing fields: {sorted(missing_fields)}"
            )

    return 0


def main() -> int:
    if len(sys.argv) != 3:
        return fail("Usage: validate-policy-artifact.py <signal|proposal> <path>")

    artifact_type = sys.argv[1]
    path = Path(sys.argv[2])
    if artifact_type not in {"signal", "proposal"}:
        return fail("Artifact type must be 'signal' or 'proposal'.")
    if not path.exists():
        return fail(f"Artifact file not found: {path}")

    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        return fail("Artifact root must be a JSON object.")

    if artifact_type == "signal":
        return validate_signal(data)
    return validate_proposal(data)


if __name__ == "__main__":
    raise SystemExit(main())
