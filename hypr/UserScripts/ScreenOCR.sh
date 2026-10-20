#!/usr/bin/env bash
# ==================================================
#  Screen Text OCR Snipping Tool
#  Captures screen region, extracts text via Tesseract,
#  and copies it to clipboard with a notification.
# ==================================================

set -euo pipefail

# Ensure tesseract is on PATH (checking ~/.local/bin and homebrew)
export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"

if ! command -v tesseract >/dev/null 2>&1; then
    notify-send -u critical -a "Screen OCR" -i "dialog-error" "OCR Error" "tesseract is not found on PATH."
    exit 1
fi

if ! command -v grim >/dev/null 2>&1 || ! command -v slurp >/dev/null 2>&1; then
    notify-send -u critical -a "Screen OCR" -i "dialog-error" "OCR Error" "grim or slurp is missing."
    exit 1
fi

TMP_DIR=$(mktemp -d /tmp/hypr_ocr.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

IMG_FILE="$TMP_DIR/capture.png"
TXT_BASE="$TMP_DIR/extracted"

# Let user select region (cancel silently on escape)
if ! GEOMETRY=$(slurp 2>/dev/null); then
    exit 0
fi

if [ -z "$GEOMETRY" ]; then
    exit 0
fi

# Capture image
grim -g "$GEOMETRY" "$IMG_FILE"

# Extract text using Tesseract (English by default, psm 6 or 3)
tesseract "$IMG_FILE" "$TXT_BASE" -l eng --psm 6 2>/dev/null || \
tesseract "$IMG_FILE" "$TXT_BASE" -l eng 2>/dev/null || true

TXT_FILE="${TXT_BASE}.txt"

if [ -f "$TXT_FILE" ]; then
    # Strip excessive blank lines and leading/trailing whitespace
    EXTRACTED=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$TXT_FILE" | awk 'NF {if (NR>1 && prev=="") print ""; print; prev=$0; next} {prev=""}')
    
    if [ -n "$EXTRACTED" ]; then
        printf "%s" "$EXTRACTED" | wl-copy
        
        # Truncate preview for notification
        PREVIEW=$(printf "%s" "$EXTRACTED" | head -n 4 | cut -c 1-80)
        notify-send -u low -a "Screen OCR" -i "accessories-character-map" \
            "Text Copied to Clipboard 📋" \
            "$PREVIEW"
    else
        notify-send -u low -a "Screen OCR" -i "dialog-information" \
            "Screen OCR" \
            "No text could be recognized in the selected area."
    fi
else
    notify-send -u low -a "Screen OCR" -i "dialog-information" \
        "Screen OCR" \
        "No text could be recognized."
fi

