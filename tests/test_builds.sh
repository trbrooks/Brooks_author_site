#!/usr/bin/env bash
# ABOUTME: Build verification tests for all AuthorPage themes.
# ABOUTME: Builds the site with each theme and checks output HTML for expected content.

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
SKIP=0
TESTED_THEMES=()
SKIPPED_THEMES=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() {
    echo -e "  ${GREEN}PASS${NC}: $1"
    ((PASS++))
}

fail() {
    echo -e "  ${RED}FAIL${NC}: $1"
    ((FAIL++))
}

skip_theme() {
    echo -e "  ${YELLOW}SKIP${NC}: $1 (missing layouts — theme not yet built)"
    ((SKIP++))
}

echo "Running AuthorPage build verification tests..."
echo "=================================="
echo ""

# Auto-discover themes
for theme_yaml in "$PROJECT_ROOT"/themes/*/theme.yaml; do
    theme_dir="$(dirname "$theme_yaml")"
    theme_name="$(basename "$theme_dir")"

    # Check if theme has layouts (skip themes that aren't built yet)
    if [ ! -d "$theme_dir/layouts" ]; then
        skip_theme "$theme_name — no layouts directory"
        SKIPPED_THEMES+=("$theme_name")
        continue
    fi

    if [ ! -f "$theme_dir/layouts/_default/baseof.html" ]; then
        skip_theme "$theme_name — no baseof.html"
        SKIPPED_THEMES+=("$theme_name")
        continue
    fi

    TESTED_THEMES+=("$theme_name")
    echo "Test group: build with $theme_name theme"

    # Build to a temp directory
    BUILD_DIR="$(mktemp -d)"
    BUILD_OUTPUT="$(hugo --source "$PROJECT_ROOT" --theme "$theme_name" --buildDrafts -d "$BUILD_DIR" 2>&1)"
    BUILD_EXIT=$?

    # Test: Hugo build succeeds
    if [ "$BUILD_EXIT" -eq 0 ]; then
        pass "Hugo build succeeds with $theme_name"
    else
        fail "Hugo build failed with $theme_name: $BUILD_OUTPUT"
        rm -rf "$BUILD_DIR"
        echo ""
        continue
    fi

    # Test: index.html exists
    if [ -f "$BUILD_DIR/index.html" ]; then
        pass "index.html exists"
    else
        fail "index.html missing"
    fi

    # Test: about page exists
    if [ -f "$BUILD_DIR/about/index.html" ]; then
        pass "about/index.html exists"
    else
        fail "about/index.html missing"
    fi

    # Test: books page exists
    if [ -f "$BUILD_DIR/books/index.html" ]; then
        pass "books/index.html exists"
    else
        fail "books/index.html missing"
    fi

    # Test: contact page exists
    if [ -f "$BUILD_DIR/contact/index.html" ]; then
        pass "contact/index.html exists"
    else
        fail "contact/index.html missing"
    fi

    # Test: blog index exists
    if [ -f "$BUILD_DIR/blog/index.html" ]; then
        pass "blog/index.html exists"
    else
        fail "blog/index.html missing"
    fi

    # Test: example blog post exists
    if ls "$BUILD_DIR"/blog/*/index.html > /dev/null 2>&1; then
        pass "blog post page exists"
    else
        fail "blog post page missing"
    fi

    # Test: HTML contains author name from data/site.yaml
    if grep -q "Jane Author" "$BUILD_DIR/index.html"; then
        pass "index.html contains author name"
    else
        fail "index.html missing author name 'Jane Author'"
    fi

    # Test: books page contains book title from data/books.yaml
    if grep -q "The Midnight Garden" "$BUILD_DIR/books/index.html"; then
        pass "books page contains book title"
    else
        fail "books page missing book title 'The Midnight Garden'"
    fi

    # Test: about page contains bio
    if grep -q "Portland" "$BUILD_DIR/about/index.html"; then
        pass "about page contains bio content"
    else
        fail "about page missing bio content"
    fi

    # Clean up
    rm -rf "$BUILD_DIR"
    echo ""
done

echo "=================================="
TOTAL=$((PASS + FAIL))
echo -e "Themes tested: ${#TESTED_THEMES[@]} (${TESTED_THEMES[*]:-none})"
if [ ${#SKIPPED_THEMES[@]} -gt 0 ]; then
    echo -e "Themes skipped: ${#SKIPPED_THEMES[@]} (${SKIPPED_THEMES[*]})"
fi
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "=================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${RED}ERROR: No themes were tested! Make sure at least one theme has layouts.${NC}"
    exit 1
fi
