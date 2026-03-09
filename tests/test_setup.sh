#!/usr/bin/env bash
# ABOUTME: Test suite for setup.sh — validates theme discovery, config generation, and error handling.
# ABOUTME: Uses real temp files and sources setup.sh functions directly for testing.

set -euo pipefail

# ---------------------------------------------------------------------------
# Test harness
# ---------------------------------------------------------------------------
PASS_COUNT=0
FAIL_COUNT=0
TEST_TMPDIR=""

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "  PASS: $1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "  FAIL: $1"
    if [[ -n "${2:-}" ]]; then
        echo "        Detail: $2"
    fi
}

# ---------------------------------------------------------------------------
# Setup / teardown helpers
# ---------------------------------------------------------------------------
create_test_project() {
    TEST_TMPDIR="$(mktemp -d)"

    # Create fake theme directories with theme.yaml files
    mkdir -p "$TEST_TMPDIR/themes/inkwell"
    cat > "$TEST_TMPDIR/themes/inkwell/theme.yaml" <<'YAML'
name: "Inkwell"
description: "Minimal and literary"
YAML

    mkdir -p "$TEST_TMPDIR/themes/paperback"
    cat > "$TEST_TMPDIR/themes/paperback/theme.yaml" <<'YAML'
name: "Paperback"
description: "Bold and commercial"
YAML

    mkdir -p "$TEST_TMPDIR/themes/typewriter"
    cat > "$TEST_TMPDIR/themes/typewriter/theme.yaml" <<'YAML'
name: "Typewriter"
description: "Retro and textured"
YAML

    # Create config.yaml matching the real project structure
    cat > "$TEST_TMPDIR/config.yaml" <<'YAML'
# ABOUTME: Main Hugo configuration file for the author website.
# ABOUTME: Controls site-wide settings, theme selection, and menu structure.

baseURL: "https://example.github.io/my-author-site/"
languageCode: "en-us"
title: "Author Site"
theme: "inkwell"

disableKinds:
  - taxonomy
  - term

params:
  description: "Author website built with AuthorPage"

menu:
  main:
    - name: "Home"
      url: "/"
      weight: 1
    - name: "Books"
      url: "/books/"
      weight: 2
    - name: "Blog"
      url: "/blog/"
      weight: 3
    - name: "About"
      url: "/about/"
      weight: 4
    - name: "Contact"
      url: "/contact/"
      weight: 5
YAML

    # Create data/site.yaml matching the real project structure
    mkdir -p "$TEST_TMPDIR/data"
    cat > "$TEST_TMPDIR/data/site.yaml" <<'YAML'
# ABOUTME: Author profile and site-wide information.
# ABOUTME: Edit this file to personalize your website.

# Your full name as you want it displayed on the site
name: "Jane Author"

# A short tagline shown under your name on the home page
tagline: "Author of The Midnight Garden"

# Your author bio — shown on the About page
bio: "Jane writes literary fiction."

# Path to your author photo (upload the image to static/images/)
photo: "/images/author.jpg"

# Your social media links (delete any you don't use)
social:
  twitter: "https://twitter.com/janeauthor"

# Email address shown on the Contact page
contact_email: "jane@example.com"
YAML
}

cleanup_test_project() {
    if [[ -n "$TEST_TMPDIR" && -d "$TEST_TMPDIR" ]]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# ---------------------------------------------------------------------------
# Source setup.sh functions (resolve path relative to this test script)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SH="$SCRIPT_DIR/../setup.sh"

if [[ ! -f "$SETUP_SH" ]]; then
    echo "ERROR: setup.sh not found at $SETUP_SH"
    exit 1
fi

# Source the script (the main guard prevents it from running interactively)
source "$SETUP_SH"

# ===========================================================================
# Tests
# ===========================================================================

echo "Running setup.sh tests..."
echo "=================================="

# ---------------------------------------------------------------------------
# Test 1: discover_themes finds all themes and extracts display names
# ---------------------------------------------------------------------------
echo ""
echo "Test group: discover_themes"

create_test_project

THEME_DIRS=()
THEME_NAMES=()
discover_themes "$TEST_TMPDIR"

if [[ ${#THEME_DIRS[@]} -eq 3 ]]; then
    pass "discover_themes found 3 themes"
else
    fail "discover_themes expected 3 themes, got ${#THEME_DIRS[@]}"
fi

# Check that theme directory names are captured (sorted order: inkwell, paperback, typewriter)
found_inkwell=false
found_paperback=false
found_typewriter=false
for dir in "${THEME_DIRS[@]}"; do
    case "$dir" in
        inkwell) found_inkwell=true ;;
        paperback) found_paperback=true ;;
        typewriter) found_typewriter=true ;;
    esac
done

if $found_inkwell && $found_paperback && $found_typewriter; then
    pass "discover_themes captured all theme directory names"
else
    fail "discover_themes missing theme directories" "inkwell=$found_inkwell paperback=$found_paperback typewriter=$found_typewriter"
fi

# Check that display names are captured
found_inkwell_name=false
found_paperback_name=false
found_typewriter_name=false
for name in "${THEME_NAMES[@]}"; do
    case "$name" in
        Inkwell) found_inkwell_name=true ;;
        Paperback) found_paperback_name=true ;;
        Typewriter) found_typewriter_name=true ;;
    esac
done

if $found_inkwell_name && $found_paperback_name && $found_typewriter_name; then
    pass "discover_themes extracted display names correctly"
else
    fail "discover_themes missing display names" "Inkwell=$found_inkwell_name Paperback=$found_paperback_name Typewriter=$found_typewriter_name"
fi

cleanup_test_project

# ---------------------------------------------------------------------------
# Test 2: discover_themes handles directory with no themes
# ---------------------------------------------------------------------------
echo ""
echo "Test group: discover_themes with no themes"

TEST_TMPDIR="$(mktemp -d)"
mkdir -p "$TEST_TMPDIR/themes"

THEME_DIRS=()
THEME_NAMES=()
discover_themes "$TEST_TMPDIR"

if [[ ${#THEME_DIRS[@]} -eq 0 ]]; then
    pass "discover_themes returns empty for directory with no themes"
else
    fail "discover_themes should return 0 themes for empty themes dir, got ${#THEME_DIRS[@]}"
fi

cleanup_test_project

# ---------------------------------------------------------------------------
# Test 3: write_config generates valid config.yaml with chosen theme
# ---------------------------------------------------------------------------
echo ""
echo "Test group: write_config"

create_test_project

write_config "$TEST_TMPDIR" "my-cool-site" "paperback"

if [[ -f "$TEST_TMPDIR/config.yaml" ]]; then
    pass "write_config created config.yaml"
else
    fail "write_config did not create config.yaml"
    cleanup_test_project
    # Skip remaining tests in this group
    echo ""
    echo "Skipping remaining write_config tests"
fi

# Check that theme is set correctly
if grep -q 'theme: "paperback"' "$TEST_TMPDIR/config.yaml"; then
    pass "write_config set theme to paperback"
else
    fail "write_config did not set theme correctly" "$(grep 'theme:' "$TEST_TMPDIR/config.yaml" 2>/dev/null || echo 'no theme line found')"
fi

# Check that the baseURL contains the repo name
if grep -q 'my-cool-site' "$TEST_TMPDIR/config.yaml"; then
    pass "write_config includes repo name in baseURL"
else
    fail "write_config missing repo name in baseURL"
fi

# Check that ABOUTME comments are preserved
if grep -q 'ABOUTME' "$TEST_TMPDIR/config.yaml"; then
    pass "write_config preserves ABOUTME comments"
else
    fail "write_config missing ABOUTME comments"
fi

# Check menu structure is preserved
if grep -q 'menu:' "$TEST_TMPDIR/config.yaml" && grep -q 'Books' "$TEST_TMPDIR/config.yaml"; then
    pass "write_config preserves menu structure"
else
    fail "write_config missing menu structure"
fi

cleanup_test_project

# ---------------------------------------------------------------------------
# Test 4: update_site_yaml updates name and tagline, preserves the rest
# ---------------------------------------------------------------------------
echo ""
echo "Test group: update_site_yaml"

create_test_project

update_site_yaml "$TEST_TMPDIR" "Rodney Harpington" "Slinger of hot takes"

if grep -q 'name: "Rodney Harpington"' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml set author name"
else
    fail "update_site_yaml did not set author name" "$(grep 'name:' "$TEST_TMPDIR/data/site.yaml" 2>/dev/null)"
fi

if grep -q 'tagline: "Slinger of hot takes"' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml set tagline"
else
    fail "update_site_yaml did not set tagline" "$(grep 'tagline:' "$TEST_TMPDIR/data/site.yaml" 2>/dev/null)"
fi

# Verify the rest of the file is preserved
if grep -q 'bio:' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml preserved bio field"
else
    fail "update_site_yaml lost bio field"
fi

if grep -q 'photo:' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml preserved photo field"
else
    fail "update_site_yaml lost photo field"
fi

if grep -q 'contact_email:' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml preserved contact_email field"
else
    fail "update_site_yaml lost contact_email field"
fi

if grep -q 'ABOUTME' "$TEST_TMPDIR/data/site.yaml"; then
    pass "update_site_yaml preserved ABOUTME comments"
else
    fail "update_site_yaml lost ABOUTME comments"
fi

cleanup_test_project

# ---------------------------------------------------------------------------
# Test 5: check_git detects missing git gracefully
# ---------------------------------------------------------------------------
echo ""
echo "Test group: check_git with fake PATH"

# Create a temporary empty directory to use as PATH so git cannot be found
EMPTY_PATH_DIR="$(mktemp -d)"
output=$(PATH="$EMPTY_PATH_DIR" check_git 2>&1 || true)
exit_code=0
PATH="$EMPTY_PATH_DIR" check_git > /dev/null 2>&1 || exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    pass "check_git exits non-zero when git is missing"
else
    fail "check_git should exit non-zero when git is missing"
fi

if echo "$output" | grep -qi "git"; then
    pass "check_git mentions git in error message"
else
    fail "check_git error message does not mention git"
fi

rm -rf "$EMPTY_PATH_DIR"

# ---------------------------------------------------------------------------
# Test 6: check_gh detects presence/absence of gh
# ---------------------------------------------------------------------------
echo ""
echo "Test group: check_gh"

EMPTY_PATH_DIR="$(mktemp -d)"
GH_AVAILABLE=true
PATH="$EMPTY_PATH_DIR" check_gh 2>/dev/null || true

if [[ "$GH_AVAILABLE" == false ]]; then
    pass "check_gh sets GH_AVAILABLE=false when gh is missing"
else
    fail "check_gh should set GH_AVAILABLE=false when gh is missing"
fi

rm -rf "$EMPTY_PATH_DIR"

# ===========================================================================
# Summary
# ===========================================================================
echo ""
echo "=================================="
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Results: $PASS_COUNT/$TOTAL passed, $FAIL_COUNT failed"
echo "=================================="

if [[ $FAIL_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
