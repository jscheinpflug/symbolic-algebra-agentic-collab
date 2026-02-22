# Safety Contract

## Partial Function Ban

The project bans the following partial functions in Haskell source:

1. `head`
2. `tail`
3. `init`
4. `last`
5. `(!!)`
6. `fromJust`
7. `read`
8. `error`
9. `undefined`

## String Type Ban

The project bans `String` and `[Char]` in Haskell source.

1. Prefer `Text` for textual data.
2. Use `ByteString` for binary or IO-oriented byte payloads.
3. Convert at external boundaries only when required by third-party APIs.

## Enforcement

1. Compiler gates:
- `-Werror`
- `-Wincomplete-patterns`
- `-Wincomplete-uni-patterns`
- `-Wincomplete-record-updates`
- `-Wpartial-fields`

2. Policy gate:
- `scripts/policy/check-no-partials.sh`
- `scripts/policy/check-no-string.sh`
- Included in `scripts/policy/check-all.sh`
- Run locally and in CI

## Preferred Alternatives

1. Use pattern matching or `NonEmpty` instead of list partials.
2. Use `Maybe`/`Either` propagation instead of `fromJust`.
3. Use explicit parser functions instead of `read`.
4. Use typed error values rather than `error`/`undefined`.
