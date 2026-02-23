#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import math
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate benchmark regressions against a checked-in baseline."
    )
    parser.add_argument(
        "--baseline",
        required=True,
        help="Path to baseline JSON (must exist).",
    )
    parser.add_argument(
        "--current-csv",
        required=True,
        help="Path to criterion CSV output for the current run.",
    )
    parser.add_argument(
        "--threshold-percent",
        type=float,
        default=10.0,
        help="Maximum allowed slowdown percentage before failing.",
    )
    parser.add_argument(
        "--output-current-json",
        required=False,
        help="Optional path to write normalized current benchmark JSON.",
    )
    parser.add_argument(
        "--output-report",
        required=False,
        help="Optional path to write a detailed comparison report JSON.",
    )
    return parser.parse_args()


def require_finite(value: float, context: str) -> float:
    if not math.isfinite(value):
        raise ValueError(f"{context} must be finite.")
    return value


def load_baseline(path: Path) -> dict[str, float]:
    if not path.exists():
        raise ValueError(f"Baseline file not found: {path}")

    raw = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise ValueError("Baseline JSON must be an object.")

    benchmarks = raw.get("benchmarks")
    if not isinstance(benchmarks, dict) or not benchmarks:
        raise ValueError("Baseline JSON must contain a non-empty 'benchmarks' object.")

    parsed: dict[str, float] = {}
    for name, value in benchmarks.items():
        if not isinstance(name, str):
            raise ValueError("Baseline benchmark names must be strings.")
        if not isinstance(value, (int, float)):
            raise ValueError(f"Baseline value for '{name}' must be numeric.")
        numeric = require_finite(float(value), f"Baseline value for '{name}'")
        if numeric <= 0:
            raise ValueError(f"Baseline value for '{name}' must be > 0.")
        parsed[name] = numeric

    return parsed


def load_current_csv(path: Path) -> dict[str, dict[str, float]]:
    if not path.exists():
        raise ValueError(f"Current CSV not found: {path}")

    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames:
            raise ValueError(f"CSV has no header row: {path}")

        header_lookup = {header.strip().lower(): header for header in reader.fieldnames}
        name_key = header_lookup.get("name")
        mean_key = header_lookup.get("mean")
        mean_lb_key = header_lookup.get("meanlb")
        mean_ub_key = header_lookup.get("meanub")

        if name_key is None or mean_key is None:
            raise ValueError(
                "Criterion CSV must contain at least 'Name' and 'Mean' columns."
            )

        parsed: dict[str, dict[str, float]] = {}
        for row_index, row in enumerate(reader, start=2):
            raw_name = row.get(name_key, "")
            raw_mean = row.get(mean_key, "")
            name = raw_name.strip()
            mean_text = raw_mean.strip()

            if not name:
                continue
            if name.lower() == "name" and mean_text.lower() == "mean":
                continue
            if not mean_text:
                raise ValueError(f"Row {row_index} missing mean value for '{name}'.")

            try:
                mean_value = require_finite(
                    float(mean_text), f"Row {row_index} mean value for '{name}'"
                )
            except ValueError as exc:
                raise ValueError(
                    f"Row {row_index} has invalid mean value '{mean_text}' for '{name}'."
                ) from exc

            if mean_value <= 0:
                raise ValueError(
                    f"Row {row_index} has non-positive mean value for '{name}'."
                )
            if name in parsed:
                raise ValueError(f"Duplicate benchmark name in CSV: '{name}'.")

            parsed[name] = {"mean": mean_value}

            if mean_lb_key is not None:
                mean_lb_text = row.get(mean_lb_key, "").strip()
                if mean_lb_text:
                    try:
                        mean_lb_value = require_finite(
                            float(mean_lb_text),
                            f"Row {row_index} MeanLB value for '{name}'",
                        )
                    except ValueError as exc:
                        raise ValueError(
                            f"Row {row_index} has invalid MeanLB value '{mean_lb_text}' for '{name}'."
                        ) from exc
                    if mean_lb_value <= 0:
                        raise ValueError(
                            f"Row {row_index} has non-positive MeanLB value for '{name}'."
                        )
                    parsed[name]["mean_lb"] = mean_lb_value

            if mean_ub_key is not None:
                mean_ub_text = row.get(mean_ub_key, "").strip()
                if mean_ub_text:
                    try:
                        mean_ub_value = require_finite(
                            float(mean_ub_text),
                            f"Row {row_index} MeanUB value for '{name}'",
                        )
                    except ValueError as exc:
                        raise ValueError(
                            f"Row {row_index} has invalid MeanUB value '{mean_ub_text}' for '{name}'."
                        ) from exc
                    if mean_ub_value <= 0:
                        raise ValueError(
                            f"Row {row_index} has non-positive MeanUB value for '{name}'."
                        )
                    parsed[name]["mean_ub"] = mean_ub_value

    if not parsed:
        raise ValueError("No benchmark rows found in current CSV.")

    return parsed


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def build_report(
    baseline: dict[str, float],
    current: dict[str, dict[str, float]],
    threshold_percent: float,
) -> dict:
    baseline_names = set(baseline)
    current_names = set(current)

    missing_in_baseline = sorted(current_names - baseline_names)
    missing_in_current = sorted(baseline_names - current_names)

    regressions: list[dict] = []
    inconclusive_slowdowns: list[dict] = []
    improvements: list[dict] = []
    within_threshold: list[dict] = []

    for name in sorted(current_names & baseline_names):
        baseline_value = baseline[name]
        current_stats = current[name]
        current_value = current_stats["mean"]
        current_lb = current_stats.get("mean_lb", current_value)
        current_ub = current_stats.get("mean_ub", current_value)
        threshold_value = baseline_value * (1.0 + (threshold_percent / 100.0))
        delta_percent = ((current_value - baseline_value) / baseline_value) * 100.0
        comparison = {
            "name": name,
            "baseline_seconds": baseline_value,
            "current_seconds": current_value,
            "current_mean_lb_seconds": current_lb,
            "current_mean_ub_seconds": current_ub,
            "threshold_seconds": threshold_value,
            "delta_percent": delta_percent,
        }

        if current_value > threshold_value and current_lb > threshold_value:
            regressions.append(comparison)
        elif current_value > threshold_value:
            inconclusive_slowdowns.append(comparison)
        elif delta_percent < 0:
            improvements.append(comparison)
        else:
            within_threshold.append(comparison)

    status = (
        "pass"
        if not missing_in_baseline and not missing_in_current and not regressions
        else "fail"
    )

    return {
        "status": status,
        "threshold_percent": threshold_percent,
        "missing_in_baseline": missing_in_baseline,
        "missing_in_current": missing_in_current,
        "regressions": regressions,
        "inconclusive_slowdowns": inconclusive_slowdowns,
        "improvements": improvements,
        "within_threshold": within_threshold,
    }


def print_summary(report: dict) -> None:
    threshold = float(report["threshold_percent"])
    regressions = report["regressions"]
    inconclusive_slowdowns = report["inconclusive_slowdowns"]
    missing_in_baseline = report["missing_in_baseline"]
    missing_in_current = report["missing_in_current"]

    print(f"Benchmark threshold: {threshold:.2f}% slowdown")

    if missing_in_baseline:
        print("Benchmarks missing from baseline:")
        for name in missing_in_baseline:
            print(f"- {name}")

    if missing_in_current:
        print("Benchmarks missing from current run:")
        for name in missing_in_current:
            print(f"- {name}")

    if regressions:
        print("Detected regressions:")
        for item in regressions:
            print(
                "- "
                f"{item['name']}: baseline={item['baseline_seconds']:.9f}s, "
                f"current={item['current_seconds']:.9f}s, "
                f"delta={item['delta_percent']:.2f}%"
            )

    if inconclusive_slowdowns:
        print("Inconclusive slowdowns (mean above threshold, confidence bound not above threshold):")
        for item in inconclusive_slowdowns:
            print(
                "- "
                f"{item['name']}: baseline={item['baseline_seconds']:.9f}s, "
                f"current={item['current_seconds']:.9f}s, "
                f"mean_lb={item['current_mean_lb_seconds']:.9f}s, "
                f"delta={item['delta_percent']:.2f}%"
            )


def main() -> int:
    args = parse_args()
    threshold_percent = require_finite(
        float(args.threshold_percent), "--threshold-percent"
    )
    if threshold_percent < 0:
        print("threshold-percent must be non-negative.", file=sys.stderr)
        return 1

    try:
        baseline = load_baseline(Path(args.baseline))
        current = load_current_csv(Path(args.current_csv))
    except (ValueError, json.JSONDecodeError) as err:
        print(f"Benchmark regression check setup failed: {err}", file=sys.stderr)
        return 1

    current_payload = {
        "version": 1,
        "unit": "seconds",
        "benchmarks": {name: values["mean"] for name, values in current.items()},
    }
    if args.output_current_json:
        write_json(Path(args.output_current_json), current_payload)

    report = build_report(baseline, current, threshold_percent)
    if args.output_report:
        write_json(Path(args.output_report), report)

    print_summary(report)

    if report["status"] != "pass":
        print("Benchmark regression gate failed.")
        return 1

    print("Benchmark regression gate passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
