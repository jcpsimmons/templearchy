#!/bin/bash
# Finder double-click. Same path as macos/Templearchy.app.
set -euo pipefail
cd "$(dirname "$0")"
exec ./macos/Templearchy.app/Contents/MacOS/Templearchy
