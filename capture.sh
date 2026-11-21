#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
run_timed() {
  /usr/bin/time -p "$@"
}

: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL to capture.}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR to the evidence output directory.}"
: "${RUNTIME_DIR:?RUNTIME_DIR must point to the installed capture runtime.}"

case "$CAPTURE_URL" in
  http://*|https://*) ;;
  *) echo 'CAPTURE_URL must be an absolute HTTP or HTTPS URL.' >&2; exit 1 ;;
esac

run_timed mkdir -p "$CAPTURE_DIR"
capture_dir="$(run_timed realpath "$CAPTURE_DIR")"
case "$capture_dir/" in
  "$PROJECT_DIR/"*) echo 'Capture evidence must be outside the project source and build directories.' >&2; exit 1 ;;
esac
[[ -f "$RUNTIME_DIR/scripts/default-capture.mjs" ]] || { echo 'The installed browser capture runtime is missing.' >&2; exit 1; }

# The runtime opens CAPTURE_URL verbatim in its own browser, checks the visible
# app shell and browser errors, writes both PNGs, then closes that browser.
run_timed env CAPTURE_READY_SELECTOR='#game-shell' CAPTURE_STRICT=1 \
  node "$RUNTIME_DIR/scripts/default-capture.mjs"
