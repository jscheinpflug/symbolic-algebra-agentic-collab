#!/usr/bin/env bash
set -euo pipefail

output_csv="artifacts/bench/workflow-benchmarks.csv"
benchmark_component="workflow-bench"
benchmark_compiler="${BENCH_GHC:-}"
benchmark_time_limit="${BENCHMARK_TIME_LIMIT:-1.0}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-csv)
      output_csv="$2"
      shift 2
      ;;
    --benchmark-component)
      benchmark_component="$2"
      shift 2
      ;;
    --time-limit)
      benchmark_time_limit="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ "${output_csv#/}" = "${output_csv}" ]; then
  output_csv="$(pwd)/${output_csv}"
fi

mkdir -p "$(dirname "${output_csv}")"
rm -f "${output_csv}"

criterion_options=(--csv "${output_csv}")
if [ -n "${benchmark_time_limit}" ]; then
  criterion_options+=(--time-limit "${benchmark_time_limit}")
fi

if [ -n "${BENCHMARK_EXTRA_OPTIONS:-}" ]; then
  # BENCHMARK_EXTRA_OPTIONS is optional and intended for local experiments.
  # shellcheck disable=SC2206
  extra_options=( ${BENCHMARK_EXTRA_OPTIONS} )
  criterion_options+=("${extra_options[@]}")
fi

if [ -z "${benchmark_compiler}" ] && command -v ghc-9.6.7 >/dev/null 2>&1; then
  benchmark_compiler="ghc-9.6.7"
fi

if [ -n "${benchmark_compiler}" ]; then
  echo "Running benchmarks with compiler: ${benchmark_compiler}"
  cabal --with-compiler="${benchmark_compiler}" bench --enable-benchmarks "${benchmark_component}" --benchmark-options="${criterion_options[*]}"
else
  echo "Running benchmarks with default compiler from PATH."
  cabal bench --enable-benchmarks "${benchmark_component}" --benchmark-options="${criterion_options[*]}"
fi

echo "Benchmark CSV written to: ${output_csv}"
