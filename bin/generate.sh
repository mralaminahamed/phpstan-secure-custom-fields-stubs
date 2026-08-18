#!/usr/bin/env bash
#
# Generate Secure Custom Fields stubs from the source directory.
#
# Produces two files:
#   1. secure-custom-fields-stubs.stub           — functions, classes, interfaces, traits
#   2. secure-custom-fields-constants-stubs.stub — constants only
#

set -e

function error_exit {
    echo "ERROR: $1" >&2
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HEADER=$'/**\n * Generated stub declarations for Secure Custom Fields.\n * @see https://wordpress.org/plugins/secure-custom-fields/\n * @see https://github.com/mralaminahamed/phpstan-secure-custom-fields-stubs\n */'
FILE="$ROOT_DIR/secure-custom-fields-stubs.stub"
FILE_CONSTANTS="$ROOT_DIR/secure-custom-fields-constants-stubs.stub"
GENERATOR_BIN="$ROOT_DIR/vendor/bin/generate-stubs"
FINDER_FILE="$ROOT_DIR/configs/finder.php"

echo "Validating requirements..."
[[ -x "$GENERATOR_BIN" ]] || error_exit "Stub generator not found or not executable at $GENERATOR_BIN"
[[ -f "$FINDER_FILE" ]] || error_exit "Finder configuration not found at $FINDER_FILE"
[[ -d "$ROOT_DIR/source/secure-custom-fields" ]] || error_exit "Source not found at $ROOT_DIR/source/secure-custom-fields"

touch "$FILE" 2>/dev/null || error_exit "Cannot create main stub file at $FILE"
touch "$FILE_CONSTANTS" 2>/dev/null || error_exit "Cannot create constants stub file at $FILE_CONSTANTS"

echo "Generating main stubs file..."
"$GENERATOR_BIN" \
    --include-inaccessible-class-nodes \
    --force \
    --finder="$FINDER_FILE" \
    --header="$HEADER" \
    --functions \
    --classes \
    --interfaces \
    --traits \
    --out="$FILE" || error_exit "Failed to generate main stubs"

echo "Generating constants stubs file..."
"$GENERATOR_BIN" \
    --include-inaccessible-class-nodes \
    --force \
    --finder="$FINDER_FILE" \
    --header="$HEADER" \
    --constants \
    --out="$FILE_CONSTANTS" || error_exit "Failed to generate constants stubs"

echo "Stub generation completed successfully."
echo "Main stubs file:      $FILE"
echo "Constants stubs file: $FILE_CONSTANTS"
