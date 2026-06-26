#!/usr/bin/env bash
# Compile main.tex into ./build/, keep only the PDF, show errors only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

BUILD_DIR="${BUILD_DIR:-build}"
MAIN_TEX="${MAIN_TEX:-main.tex}"
JOB="${MAIN_TEX%.tex}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [build|clean]

  build   Compile PDF (default). Output: ${BUILD_DIR}/${JOB}.pdf
  clean   Remove ${BUILD_DIR}/

Environment:
  BUILD_DIR   Output directory (default: build)
  MAIN_TEX    Root .tex file (default: main.tex)
EOF
}

collect_errors() {
  local -a logs=()
  local log

  for log in "$BUILD_DIR/$JOB.log" "$BUILD_DIR/$JOB.blg"; do
    [[ -f "$log" ]] && logs+=("$log")
  done

  [[ ${#logs[@]} -eq 0 ]] && return 0

  grep -hE \
    -e '^! ' \
    -e '^l\.[0-9]+ ' \
    -e ':[0-9]+:[0-9]+: error:' \
    -e 'LaTeX Error:' \
    -e 'Package .* Error' \
    -e 'Emergency stop\.' \
    -e 'Fatal error' \
    -e '==> Fatal error' \
    -e 'Biber ERROR' \
    -e '^ERROR -' \
    "${logs[@]}" 2>/dev/null | sort -u || true
}

run_pdflatex() {
  pdflatex \
    -interaction=nonstopmode \
    -file-line-error \
    -shell-escape \
    -output-directory="$BUILD_DIR" \
    "$MAIN_TEX" >/dev/null 2>&1 || true
}

run_biber() {
  if [[ ! -f "$BUILD_DIR/$JOB.bcf" ]]; then
    return 0
  fi
  if command -v biber >/dev/null 2>&1; then
    biber --output-directory="$BUILD_DIR" "$JOB" >/dev/null 2>&1 || true
  fi
}

cleanup_build() {
  [[ -d "$BUILD_DIR" ]] || return 0
  find "$BUILD_DIR" -mindepth 1 ! -iname '*.pdf' -exec rm -rf {} +
}

do_build() {
  mkdir -p "$BUILD_DIR"

  run_pdflatex
  run_biber
  run_pdflatex
  run_pdflatex

  local errors
  errors="$(collect_errors)"

  if [[ -n "$errors" ]]; then
    printf '%s\n' "$errors" >&2
  fi

  cleanup_build

  if [[ ! -f "$BUILD_DIR/$JOB.pdf" ]]; then
    echo "error: $BUILD_DIR/$JOB.pdf was not produced" >&2
    exit 1
  fi

  if [[ -n "$errors" ]]; then
    exit 1
  fi

  echo "OK: $BUILD_DIR/$JOB.pdf"
}

do_clean() {
  rm -rf "$BUILD_DIR"
  echo "Removed $BUILD_DIR/"
}

case "${1:-build}" in
  build) do_build ;;
  clean) do_clean ;;
  -h|--help|help) usage ;;
  *)
    echo "error: unknown command: $1" >&2
    usage >&2
    exit 2
    ;;
esac
