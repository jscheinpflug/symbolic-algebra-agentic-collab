#!/usr/bin/env bash
set -euo pipefail

probe=0
prompt="say hello"
timeout_seconds=30

while [[ $# -gt 0 ]]; do
  case "$1" in
    --probe)
      probe=1
      shift
      ;;
    --prompt)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --prompt" >&2
        exit 2
      fi
      prompt="$2"
      shift 2
      ;;
    --timeout)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --timeout" >&2
        exit 2
      fi
      timeout_seconds="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

check_binary() {
  local bin="$1"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "[ok] $bin found"
    return 0
  fi
  echo "[missing] $bin not found"
  return 1
}

probe_model() {
  local name="$1"
  shift
  if timeout "${timeout_seconds}" "$@" >/dev/null 2>&1; then
    echo "[ok] ${name} probe succeeded"
    return 0
  fi

  local rc=$?
  if [[ ${rc} -eq 124 ]]; then
    echo "[timeout] ${name} probe timed out after ${timeout_seconds}s"
  else
    echo "[fail] ${name} probe failed (exit ${rc})"
  fi
  return 1
}

failures=0

check_binary "codex" || failures=$((failures + 1))
check_binary "claude" || failures=$((failures + 1))
check_binary "gemini" || failures=$((failures + 1))

if [[ ${probe} -eq 1 ]]; then
  echo "Running non-interactive probes with prompt: ${prompt}"
  probe_model "codex" codex exec "${prompt}" || failures=$((failures + 1))
  probe_model "claude" claude -p "${prompt}" || failures=$((failures + 1))
  probe_model "gemini" gemini "${prompt}" || failures=$((failures + 1))
fi

if [[ ${failures} -gt 0 ]]; then
  echo "CLI health check failed (${failures} issue(s))." >&2
  exit 1
fi

echo "CLI health check passed."
