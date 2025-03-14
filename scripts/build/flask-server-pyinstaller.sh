#!/bin/bash

# A script used for generating an executable file using the python `pyinstaller` utility.

# # Minimum required Python version
# MIN_PYTHON_VERSION="3.9"

# # Compare installed Python versions for compatibility check.
# USER_PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
# if [[ $? -ne 0 ]]; then
#     echo "Python 3 is not installed or not found in PATH."
#     exit 1
# fi
# if [[ "$(printf '%s\n' "$MIN_PYTHON_VERSION" "$python_version" | sort -V | head -n1)" != "$MIN_PYTHON_VERSION" ]]; then
#     echo "Python version is below $MIN_PYTHON_VERSION. Found: $python_version"
#     exit 1
# fi
# echo "Python version $python_version meets the requirement."

# # Check for pyinstaller installation and install if necessary.
# echo "Checking if pyinstaller is installed..."
# python3 -m pyinstaller --version >/dev/null 2>&1
# if ! [[ $? -eq 0 ]]; then
#     echo "PyInstaller is not installed. Installing pyinstaller..."
#     python3 -m pip install --upgrade pip >/dev/null 2>&1
#     python3 -m pip install pyinstaller >/dev/null 2>&1
#     if [[ $? -ne 0 ]]; then
#         echo "Failed to install pyinstaller. Please check your Python environment."
#         exit 1
#     fi
#     echo "PyInstaller installed successfully."
# fi
# echo "PyInstaller is already installed."

# Change current project directory to the Python Flask project folder.
SCRIPT_DIR=$(dirname $(realpath "$0"))
source "$SCRIPT_DIR/../source.sh"
cd $PROJECT_DIR/backend/flask/

# Run the `pyinstaller` utility, creating a single executable in the `dist` directory.
pyinstaller --onefile --noconsole main.py