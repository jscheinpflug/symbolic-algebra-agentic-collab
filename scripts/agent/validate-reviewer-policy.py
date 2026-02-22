#!/usr/bin/env python3
from __future__ import annotations

import argparse
import copy
import json
import sys
from pathlib import Path
from typing import Any, Final

REQUIRED_REVIEWERS: Final[tuple[str, ...]] = ("claude", "gemini", "codex")


class PolicyValidationError(Exception):
    pass


def validate_condition(condition: bool, message: str) -> None:
    if not condition:
        raise PolicyValidationError(message)


def parse_json_file(file_path: Path) -> Any:
    try:
        return json.loads(file_path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise PolicyValidationError(f"Reviewer policy file not found: {file_path}") from error
    except json.JSONDecodeError as error:
        raise PolicyValidationError(
            f"Reviewer policy JSON decode failed at line {error.lineno}, column {error.colno}: {error.msg}"
        ) from error


def validate_policy(data: Any) -> dict[str, Any]:
    validate_condition(isinstance(data, dict), "Reviewer policy must be a JSON object.")

    required_top_level = {"version", "reviewers", "minimum_required_approvals"}
    keys = set(data.keys())
    missing_top_level = sorted(required_top_level - keys)
    extra_top_level = sorted(keys - required_top_level)
    validate_condition(
        not missing_top_level,
        f"Reviewer policy missing required top-level keys: {missing_top_level}",
    )
    validate_condition(
        not extra_top_level,
        f"Reviewer policy has unknown top-level keys: {extra_top_level}",
    )

    version = data["version"]
    validate_condition(
        isinstance(version, int) and not isinstance(version, bool),
        "Reviewer policy field 'version' must be an integer.",
    )
    validate_condition(version == 1, f"Unsupported reviewer policy version: {version}")

    reviewers = data["reviewers"]
    validate_condition(
        isinstance(reviewers, dict),
        "Reviewer policy field 'reviewers' must be an object.",
    )

    reviewer_keys = set(reviewers.keys())
    expected_reviewer_keys = set(REQUIRED_REVIEWERS)
    missing_reviewers = sorted(expected_reviewer_keys - reviewer_keys)
    extra_reviewers = sorted(reviewer_keys - expected_reviewer_keys)
    validate_condition(
        not missing_reviewers,
        f"Reviewer policy missing reviewer entries: {missing_reviewers}",
    )
    validate_condition(
        not extra_reviewers,
        f"Reviewer policy has unknown reviewer entries: {extra_reviewers}",
    )

    normalized_reviewers: dict[str, dict[str, bool]] = {}
    enabled_reviewer_count = 0
    for reviewer in REQUIRED_REVIEWERS:
        reviewer_entry = reviewers[reviewer]
        validate_condition(
            isinstance(reviewer_entry, dict),
            f"Reviewer policy entry for '{reviewer}' must be an object.",
        )

        reviewer_entry_keys = set(reviewer_entry.keys())
        validate_condition(
            "enabled" in reviewer_entry_keys,
            f"Reviewer policy entry for '{reviewer}' is missing required field 'enabled'.",
        )
        unknown_reviewer_fields = sorted(reviewer_entry_keys - {"enabled"})
        validate_condition(
            not unknown_reviewer_fields,
            f"Reviewer policy entry for '{reviewer}' has unknown fields: {unknown_reviewer_fields}",
        )

        enabled_value = reviewer_entry["enabled"]
        validate_condition(
            isinstance(enabled_value, bool),
            f"Reviewer policy field 'reviewers.{reviewer}.enabled' must be a boolean.",
        )

        if enabled_value:
            enabled_reviewer_count += 1

        normalized_reviewers[reviewer] = {"enabled": enabled_value}

    minimum_required_approvals = data["minimum_required_approvals"]
    validate_condition(
        isinstance(minimum_required_approvals, int) and not isinstance(minimum_required_approvals, bool),
        "Reviewer policy field 'minimum_required_approvals' must be an integer.",
    )
    validate_condition(
        minimum_required_approvals >= 1,
        "Reviewer policy field 'minimum_required_approvals' must be >= 1.",
    )
    validate_condition(
        enabled_reviewer_count >= 2,
        "Reviewer policy requires at least 2 reviewers enabled.",
    )
    validate_condition(
        minimum_required_approvals <= enabled_reviewer_count,
        "Reviewer policy field 'minimum_required_approvals' cannot exceed enabled reviewer count.",
    )

    return {
        "version": 1,
        "reviewers": normalized_reviewers,
        "minimum_required_approvals": minimum_required_approvals,
    }


def valid_baseline_policy() -> dict[str, Any]:
    return {
        "version": 1,
        "reviewers": {
            "claude": {"enabled": True},
            "gemini": {"enabled": False},
            "codex": {"enabled": True},
        },
        "minimum_required_approvals": 2,
    }


def run_self_test() -> int:
    cases: list[tuple[str, dict[str, Any], bool, str]] = []

    baseline = valid_baseline_policy()
    cases.append(("valid baseline policy", baseline, True, ""))

    missing_reviewer = copy.deepcopy(baseline)
    del missing_reviewer["reviewers"]["gemini"]
    cases.append(("missing reviewer key", missing_reviewer, False, "missing reviewer entries"))

    non_boolean_enabled = copy.deepcopy(baseline)
    non_boolean_enabled["reviewers"]["gemini"]["enabled"] = "false"
    cases.append(
        ("non-boolean enabled value", non_boolean_enabled, False, "must be a boolean")
    )

    fewer_than_two_enabled = copy.deepcopy(baseline)
    fewer_than_two_enabled["reviewers"]["claude"]["enabled"] = False
    cases.append(
        ("fewer than two enabled reviewers", fewer_than_two_enabled, False, "at least 2 reviewers enabled")
    )

    approvals_exceed_enabled = copy.deepcopy(baseline)
    approvals_exceed_enabled["minimum_required_approvals"] = 3
    cases.append(
        ("minimum approvals exceed enabled reviewers", approvals_exceed_enabled, False, "cannot exceed enabled reviewer count")
    )

    failures: list[str] = []
    for name, payload, should_pass, expected_message in cases:
        try:
            validate_policy(payload)
            if not should_pass:
                failures.append(f"{name}: expected failure but validation passed")
        except PolicyValidationError as error:
            if should_pass:
                failures.append(f"{name}: expected success but failed: {error}")
            elif expected_message and expected_message not in str(error):
                failures.append(
                    f"{name}: expected error containing '{expected_message}', got '{error}'"
                )

    if failures:
        for failure in failures:
            print(f"Self-test failed: {failure}", file=sys.stderr)
        return 1

    print("Reviewer policy self-test passed.")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate repository reviewer policy for trusted agent review workflow."
    )
    parser.add_argument(
        "--file",
        type=Path,
        help="Path to reviewer policy JSON file.",
    )
    parser.add_argument(
        "--print-normalized-json",
        action="store_true",
        help="Print normalized validated policy JSON to stdout.",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Run built-in validator self-tests.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    ran_any = False

    if args.file is not None:
        policy_data = parse_json_file(args.file)
        normalized = validate_policy(policy_data)
        ran_any = True
        if args.print_normalized_json:
            print(json.dumps(normalized, indent=2, sort_keys=True))

    if args.self_test:
        ran_any = True
        self_test_result = run_self_test()
        if self_test_result != 0:
            return self_test_result

    if not ran_any:
        print("Expected at least one action: --file <path> and/or --self-test.", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except PolicyValidationError as error:
        print(f"Reviewer policy validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)
