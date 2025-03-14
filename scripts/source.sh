#!/bin/bash

# Script used for retrieving and exporting the values of the script and the project directories.

export PROJECT_DIR="$(dirname "$(readlink -f "$0")")/.."

echo "AAA"