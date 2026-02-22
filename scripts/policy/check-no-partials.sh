#!/usr/bin/env bash
set -euo pipefail

targets=(src app test)

declare -a checks=(
  "head|(?<![\"'])\\bhead\\b(?![\"'])"
  "tail|(?<![\"'])\\btail\\b(?![\"'])"
  "init|(?<![\"'])\\binit\\b(?![\"'])"
  "last|(?<![\"'])\\blast\\b(?![\"'])"
  "index-operator|(?<![\"'])!!(?![\"'])"
  "fromJust|(?<![\"'])\\bfromJust\\b(?![\"'])"
  "read|(?<![\"'])\\bread\\b(?![\"'])"
  "error|(?<![\"'])\\berror\\b(?![\"'])"
  "undefined|(?<![\"'])\\bundefined\\b(?![\"'])"
)

failed=0

for entry in "${checks[@]}"; do
  name="${entry%%|*}"
  pattern="${entry#*|}"
  matches="$(rg -n --pcre2 --glob '*.hs' "$pattern" "${targets[@]}" || true)"
  if [ -n "$matches" ]; then
    echo "Banned partial usage detected (${name}):"
    echo "$matches"
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "No banned partial functions found."
