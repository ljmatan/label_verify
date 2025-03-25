#!/bin/bash

# Build Python middleware server support files, and move them to an appropriate location.
#
# Example usage:
# 
# sh scripts/build-middleware.sh

# Define script and project folder paths.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR="$SCRIPT_DIR/.."

# Change current working directory to the server support folder.
cd "$PROJECT_DIR/middleware"

# Generate the executable using PyInstaller.
pyinstaller main.py --onefile

# Move the generated binary to the assets directory.
ASSET_BINARY_PATH="$PROJECT_DIR/assets/bin/python.exec"
rm -rf "$ASSET_BINARY_PATH" || echo "Python binary is not in the assets directory."
mv -f "./dist/main" "$ASSET_BINARY_PATH"