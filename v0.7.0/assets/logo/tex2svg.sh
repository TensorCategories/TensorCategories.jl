#!/usr/bin/env bash

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 file.tex"
  exit 1
fi

TEXFILE="$1"
BASENAME="$(basename "$TEXFILE" .tex)"
TMPDIR=".tmp"

mkdir -p "$TMPDIR"

echo "Compiling LaTeX..."

latex -interaction=nonstopmode -halt-on-error \
  -output-directory="$TMPDIR" \
  "$TEXFILE" >/dev/null

DVIFILE="$TMPDIR/$BASENAME.dvi"

if [ ! -f "$DVIFILE" ]; then
  echo "Error: DVI file not found."
  exit 1
fi

echo "Converting to SVG..."

dvisvgm "$DVIFILE" -n -o "$BASENAME.svg"

echo "Done: $BASENAME.svg"
