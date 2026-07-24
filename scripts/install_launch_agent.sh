#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LABEL="com.example.zotero-llm"
SOURCE_PLIST="$PROJECT_DIR/launchd/$LABEL.plist"
TARGET_PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
BOOTSTRAP_DOMAIN="gui/$(id -u)"

mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$HOME/Zotero/OCR_OUTPUT/.state/logs"

plutil -lint "$SOURCE_PLIST" >/dev/null
cp "$SOURCE_PLIST" "$TARGET_PLIST"

launchctl bootout "$BOOTSTRAP_DOMAIN" "$TARGET_PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "$BOOTSTRAP_DOMAIN" "$TARGET_PLIST"
launchctl enable "$BOOTSTRAP_DOMAIN/$LABEL"
launchctl print "$BOOTSTRAP_DOMAIN/$LABEL" | sed -n '1,80p'
