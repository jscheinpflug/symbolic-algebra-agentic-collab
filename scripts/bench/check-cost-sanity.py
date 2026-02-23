#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path


EXPECTED_ORDER: list[str] = [
    "workflow/reject-resubmit-cycles-50000",
    "workflow/reject-resubmit-cycles-100000",
    "workflow/reject-resubmit-cycles-200000",
    "workflow/reject-resubmit-cycles-400000",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate benchmark cost ordering to catch harness regressions that "
            "flatten scenario costs."
        )
    )
    parser.add_argument(
        "--bench-json",
        required=True,
        help="Path to benchmark JSON containing a 'benchmarks' object.",
    )
    parser.add_argument(
        "--min-ratio",
        type=float,
        default=5.0,
        help=(
            "Minimum required ratio between slowest and fastest expected scenario "
            "(default: 5.0)."
        ),
    )
    return parser.parse_args()


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


def require_finite(value: float, context: str) -> float:
    if not math.isfinite(value):
        raise ValueError(f"{context} must be finite.")
    return value


def main() -> int:
    args = parse_args()
    try:
        min_ratio = require_finite(float(args.min_ratio), "--min-ratio")
    except ValueError as error:
        return fail(str(error))

    if min_ratio <= 1.0:
        return fail("--min-ratio must be > 1.0")

    bench_path = Path(args.bench_json)
    if not bench_path.exists():
        return fail(f"Benchmark JSON file not found: {bench_path}")

    try:
        payload = json.loads(bench_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        return fail(
            "Benchmark JSON decode failed at "
            f"line {error.lineno}, column {error.colno}: {error.msg}"
        )

    if not isinstance(payload, dict):
        return fail("Benchmark JSON must be an object.")

    benchmarks = payload.get("benchmarks")
    if not isinstance(benchmarks, dict):
        return fail("Benchmark JSON must contain a 'benchmarks' object.")

    values: dict[str, float] = {}
    for name in EXPECTED_ORDER:
        if name not in benchmarks:
            return fail(f"Missing expected benchmark key: {name}")

        value = benchmarks[name]
        if not isinstance(value, (int, float)):
            return fail(f"Benchmark value for '{name}' must be numeric.")

        try:
            numeric = require_finite(float(value), f"Benchmark value for '{name}'")
        except ValueError as error:
            return fail(str(error))
        if numeric <= 0.0:
            return fail(f"Benchmark value for '{name}' must be > 0.")
        values[name] = numeric

    for fast_name, slow_name in zip(EXPECTED_ORDER, EXPECTED_ORDER[1:]):
        fast_value = values[fast_name]
        slow_value = values[slow_name]
        if slow_value <= fast_value:
            return fail(
                "Benchmark cost ordering violated: "
                f"expected '{slow_name}' ({slow_value:.9f}s) "
                f"> '{fast_name}' ({fast_value:.9f}s)."
            )

    fastest = values[EXPECTED_ORDER[0]]
    slowest = values[EXPECTED_ORDER[-1]]
    ratio = slowest / fastest
    if not math.isfinite(ratio):
        return fail("Computed slowest/fastest ratio must be finite.")
    if ratio < min_ratio:
        return fail(
            "Benchmark spread too narrow for expected complexity: "
            f"slowest/fastest ratio={ratio:.3f}, required>={min_ratio:.3f}."
        )

    print(
        "Benchmark cost sanity check passed: "
        f"slowest/fastest ratio={ratio:.3f} using {bench_path}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
