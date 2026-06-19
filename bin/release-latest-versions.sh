#!/usr/bin/env bash
#
# Generate Secure Custom Fields stubs for the latest N stable versions.
#
# Fetches versions from WordPress.org, keeps the N newest STABLE releases
# (beta/RC/trunk excluded), and for each not-yet-tagged version: downloads the
# plugin, generates stubs, commits, and tags v<version>.
#
# Usage: bash bin/release-latest-versions.sh [N]   (default N=5)
#

set -e

function error_exit { echo "ERROR: $1" >&2; exit 1; }
function check_command { command -v "$1" >/dev/null 2>&1 || error_exit "Required command '$1' not found"; }
function log_step { echo "==> $1"; }

KEEP="${1:-5}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$ROOT_DIR/secure-custom-fields_versions.txt"
PLUGIN_NAME="secure-custom-fields"
PLUGIN_API_URL="https://api.wordpress.org/plugins/info/1.0/$PLUGIN_NAME.json"
SOURCE_DIR="$ROOT_DIR/source"
GENERATE_SCRIPT="$SCRIPT_DIR/generate.sh"
BRANCH_NAME="main"

log_step "Checking required commands..."
check_command curl; check_command jq; check_command unzip; check_command git

[[ -x "$GENERATE_SCRIPT" ]] || error_exit "Generate script not found or not executable: $GENERATE_SCRIPT"

log_step "Fetching plugin information from WordPress.org..."
WP_JSON="$(curl -s "$PLUGIN_API_URL")" || error_exit "Failed to fetch plugin information"

# Stable versions only (strip pre-release such as -beta/-rc), newest last, keep N.
log_step "Selecting the latest $KEEP stable version(s)..."
jq -r '."versions" | keys[]' <<<"$WP_JSON" \
    | grep -vi "trunk" \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -n "$KEEP" > "$OUTPUT_FILE"

[ -s "$OUTPUT_FILE" ] || error_exit "No stable versions found"
echo "Versions to process:"; sed 's/^/  - /' "$OUTPUT_FILE"

while IFS= read -r VERSION; do
    [ -z "$VERSION" ] && continue
    log_step "Processing version ${VERSION}..."

    if git -C "$ROOT_DIR" rev-parse "refs/tags/v${VERSION}" >/dev/null 2>&1; then
        echo "  - Tag v${VERSION} exists, skipping."
        continue
    fi

    echo "  - Cleaning source directory..."
    find "$SOURCE_DIR/" -mindepth 1 ! -name 'composer.json' ! -name '.gitignore' -exec rm -rf {} + 2>/dev/null || true

    DOWNLOAD_URL="https://downloads.wordpress.org/plugin/${PLUGIN_NAME}.${VERSION}.zip"
    DOWNLOAD_PATH="$SOURCE_DIR/${PLUGIN_NAME}.${VERSION}.zip"

    echo "  - Downloading ${VERSION}..."
    if ! curl -s -L -o "$DOWNLOAD_PATH" "$DOWNLOAD_URL"; then
        echo "  - Failed to download ${VERSION}, skipping."
        continue
    fi

    echo "  - Extracting..."
    if ! unzip -q -o -d "$SOURCE_DIR/" "$DOWNLOAD_PATH"; then
        echo "  - Failed to extract ${VERSION}, skipping."
        rm -f "$DOWNLOAD_PATH"; continue
    fi
    rm -f "$DOWNLOAD_PATH"

    echo "  - Generating stubs..."
    if ! "$GENERATE_SCRIPT"; then
        echo "  - Failed to generate stubs for ${VERSION}, skipping."
        find "$SOURCE_DIR/" -mindepth 1 ! -name 'composer.json' ! -name '.gitignore' -exec rm -rf {} + 2>/dev/null || true
        continue
    fi

    find "$SOURCE_DIR/" -mindepth 1 ! -name 'composer.json' ! -name '.gitignore' -exec rm -rf {} + 2>/dev/null || true

    if git -C "$ROOT_DIR" diff-index --quiet HEAD --; then
        echo "  - No changes for ${VERSION}, tagging current HEAD."
        git -C "$ROOT_DIR" tag "v${VERSION}"
    else
        echo "  - Committing and tagging ${VERSION}..."
        git -C "$ROOT_DIR" add .
        git -C "$ROOT_DIR" commit -m "Generate stubs for Secure Custom Fields ${VERSION}"
        git -C "$ROOT_DIR" tag "v${VERSION}"
    fi
done < "$OUTPUT_FILE"

log_step "Done. Tags: $(git -C "$ROOT_DIR" tag | tr '\n' ' ')"
echo
echo "Push with:  git push origin $BRANCH_NAME --follow-tags"
