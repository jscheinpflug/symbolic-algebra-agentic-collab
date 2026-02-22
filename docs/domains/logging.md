# Logging Contract

## Goals

1. Replace ad hoc runtime printing with structured logging.
2. Keep production logging overhead low by default.
3. Control log behavior entirely through typed config and environment variables.

## Runtime Policy

1. `APP_ENV=prod` defaults to no-op logging.
2. `APP_ENV=dev` defaults to `Info` logs on stderr.
3. `APP_ENV=ci` defaults to `Info` logs on stderr.
4. `LOG_LEVEL` can override level (`debug`, `info`, `warn`, `error`).
5. `LOG_SINK` can override sink (`stderr`, `noop`, `file:/path/to/log`).

## API

- `LogLevel`: `Debug | Info | Warn | Error`
- `LogSink`: `StdErr | FilePathSink FilePath | NoOp`
- `LogConfig`: typed logging configuration
- `withLogging`: applies logger configuration for an `IO` action
- `MonadLog`: capability for code that emits structured log messages

## Usage Guidance

1. Use logs for runtime state transitions, failures, and timing.
2. Keep comments for design intent, invariants, and mathematical rationale.
3. Do not treat logs as documentation substitutes.
