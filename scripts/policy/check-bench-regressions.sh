#!/usr/bin/env bash
set -euo pipefail

baseline_file="bench/baseline/workflow-benchmarks.json"
output_dir="${BENCH_OUTPUT_DIR:-artifacts/bench}"
threshold_percent="${BENCH_REGRESSION_THRESHOLD_PERCENT:-10}"
sanity_min_ratio="${BENCH_COST_SANITY_MIN_RATIO:-5}"

if [ ! -f "${baseline_file}" ]; then
  echo "Missing benchmark baseline: ${baseline_file}" >&2
  exit 1
fi

csv_output="${output_dir}/workflow-benchmarks.csv"
current_json="${output_dir}/workflow-benchmarks-current.json"
report_json="${output_dir}/workflow-benchmarks-regression-report.json"

python3 scripts/bench/check-cost-sanity.py \
  --bench-json "${baseline_file}" \
  --min-ratio "${sanity_min_ratio}"

./scripts/bench/run-benchmarks.sh --output-csv "${csv_output}"

python3 scripts/bench/check-regressions.py \
  --baseline "${baseline_file}" \
  --current-csv "${csv_output}" \
  --threshold-percent "${threshold_percent}" \
  --output-current-json "${current_json}" \
  --output-report "${report_json}"

python3 scripts/bench/check-cost-sanity.py \
  --bench-json "${current_json}" \
  --min-ratio "${sanity_min_ratio}"
