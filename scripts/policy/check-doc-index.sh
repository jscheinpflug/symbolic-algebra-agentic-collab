#!/usr/bin/env bash
set -euo pipefail

index_file="docs/index.md"
if [ ! -f "$index_file" ]; then
  echo "Missing $index_file"
  exit 1
fi

mapfile -t referenced_paths < <(grep -oE '`[^`]+`' "$index_file" | tr -d '`')

if [ "${#referenced_paths[@]}" -eq 0 ]; then
  echo "No referenced paths found in $index_file"
  exit 1
fi

missing=0
for path in "${referenced_paths[@]}"; do
  case "$path" in
    AGENTS.md|README.md|docs/*|schemas/*|scripts/*|bench/*|.github/*|.agent-reviewer-policy.json|symbolic-algebra-agentic-collab.cabal)
      if [ ! -e "$path" ]; then
        echo "docs/index.md references missing path: $path"
        missing=1
      fi
      ;;
    *)
      ;;
  esac
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "Documentation index check passed."
