#!/usr/bin/env bash
set -euo pipefail

targets=(src app test bench)

declare -a checks=(
  "String-type|(?<![\"'])\\bString\\b(?![\"'])"
  "Char-list-type|(?<![\"'])\\[\\s*Char\\s*\\](?![\"'])"
)

failed=0

for entry in "${checks[@]}"; do
  name="${entry%%|*}"
  pattern="${entry#*|}"
  matches="$(rg -n --pcre2 --glob '*.hs' "$pattern" "${targets[@]}" || true)"
  if [ -n "$matches" ]; then
    echo "Banned string representation detected (${name}):"
    echo "$matches"
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "No banned String/[Char] usage found."
