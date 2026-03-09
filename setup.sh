#!/usr/bin/env bash
# ABOUTME: Interactive CLI setup script for AuthorPage — takes an author from zero to live website.
# ABOUTME: Prompts for author info, discovers themes, writes config, and optionally creates a GitHub repo.

set -euo pipefail

# ---------------------------------------------------------------------------
# Global state populated by functions
# ---------------------------------------------------------------------------
THEME_DIRS=()
THEME_NAMES=()
GH_AVAILABLE=true

# ---------------------------------------------------------------------------
# Functions (designed to be sourced independently for testing)
# ---------------------------------------------------------------------------

print_banner() {
    echo ""
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║         Welcome to AuthorPage!           ║"
    echo "  ║   Your author website in one command.    ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo ""
}

# Check that git is installed. Exits with error if missing.
check_git() {
    if ! command -v git &> /dev/null; then
        echo "ERROR: git is required but not installed."
        echo "  Install it from: https://git-scm.com/downloads"
        return 1
    fi
}

# Check if gh (GitHub CLI) is available. Sets GH_AVAILABLE=true/false.
check_gh() {
    if ! command -v gh &> /dev/null; then
        GH_AVAILABLE=false
        echo "NOTE: GitHub CLI (gh) is not installed."
        echo "  You can still set up the site, but repo creation will be manual."
        echo "  Install gh from: https://cli.github.com/"
        echo ""
    else
        GH_AVAILABLE=true
    fi
}

# Discover available themes by scanning themes/*/theme.yaml.
# Populates THEME_DIRS (directory basenames) and THEME_NAMES (display names).
# Args: $1 = project root directory
discover_themes() {
    local project_root="$1"
    THEME_DIRS=()
    THEME_NAMES=()

    local theme_yaml
    for theme_yaml in "$project_root"/themes/*/theme.yaml; do
        # Guard against the glob not matching anything
        [[ -f "$theme_yaml" ]] || continue

        local dir_path
        dir_path="$(dirname "$theme_yaml")"
        local dir_name
        dir_name="$(basename "$dir_path")"

        # Extract the name field from theme.yaml using grep/sed (no yq dependency)
        local display_name
        display_name="$(sed -n 's/^name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$theme_yaml" | head -1)"

        if [[ -n "$display_name" ]]; then
            THEME_DIRS+=("$dir_name")
            THEME_NAMES+=("$display_name")
        fi
    done
}

# Write config.yaml with the chosen theme and repo name.
# Args: $1 = project root, $2 = repo name, $3 = theme directory name
write_config() {
    local project_root="$1"
    local repo_name="$2"
    local theme="$3"

    cat > "$project_root/config.yaml" <<EOF
# ABOUTME: Main Hugo configuration file for the author website.
# ABOUTME: Controls site-wide settings, theme selection, and menu structure.

baseURL: "https://example.github.io/${repo_name}/"
languageCode: "en-us"
title: "Author Site"
theme: "${theme}"

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
EOF
}

# Update data/site.yaml with author name and tagline, preserving everything else.
# Args: $1 = project root, $2 = author name, $3 = tagline
update_site_yaml() {
    local project_root="$1"
    local author_name="$2"
    local tagline="$3"
    local site_yaml="$project_root/data/site.yaml"

    # Use sed to replace only the name and tagline lines
    sed -i.bak "s/^name: .*/name: \"${author_name}\"/" "$site_yaml"
    sed -i.bak "s/^tagline: .*/tagline: \"${tagline}\"/" "$site_yaml"

    # Clean up backup files created by sed -i on macOS
    rm -f "${site_yaml}.bak"
}

# ---------------------------------------------------------------------------
# Main interactive flow
# ---------------------------------------------------------------------------
main() {
    local project_root
    project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    print_banner

    # --- Prerequisite checks ---
    check_git
    check_gh

    # --- Discover themes ---
    discover_themes "$project_root"

    if [[ ${#THEME_DIRS[@]} -eq 0 ]]; then
        echo "ERROR: No themes found in themes/. Something is wrong with your installation."
        exit 1
    fi

    # --- Prompt: Author name ---
    read -rp "Your name [Author Name]: " author_name
    author_name="${author_name:-Author Name}"

    # --- Prompt: Tagline ---
    read -rp "Your tagline [Writer of stories]: " tagline
    tagline="${tagline:-Writer of stories}"

    # --- Prompt: Theme selection ---
    echo ""
    echo "Available themes:"
    for i in "${!THEME_NAMES[@]}"; do
        echo "  $((i + 1)). ${THEME_NAMES[$i]}"
    done
    echo ""
    read -rp "Choose a theme [1]: " theme_choice
    theme_choice="${theme_choice:-1}"

    # Validate selection
    local theme_index=$((theme_choice - 1))
    if [[ $theme_index -lt 0 || $theme_index -ge ${#THEME_DIRS[@]} ]]; then
        echo "Invalid selection. Using default theme."
        theme_index=0
    fi
    local chosen_theme="${THEME_DIRS[$theme_index]}"
    local chosen_theme_name="${THEME_NAMES[$theme_index]}"
    echo "  Selected: ${chosen_theme_name}"

    # --- Prompt: Repo name ---
    echo ""
    read -rp "GitHub repo name [my-author-site]: " repo_name
    repo_name="${repo_name:-my-author-site}"

    # --- Write configuration files ---
    echo ""
    echo "Writing configuration..."
    write_config "$project_root" "$repo_name" "$chosen_theme"
    echo "  config.yaml updated (theme: ${chosen_theme})"

    update_site_yaml "$project_root" "$author_name" "$tagline"
    echo "  data/site.yaml updated (name: ${author_name})"

    # --- Git + GitHub ---
    echo ""
    if [[ "$GH_AVAILABLE" == true ]]; then
        echo "Creating GitHub repository..."
        gh repo create "$repo_name" --public --source=. --push

        # Enable GitHub Pages with workflow-based builds
        local owner_repo
        owner_repo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
        gh api "repos/${owner_repo}/pages" -X POST -f build_type=workflow 2>/dev/null || true

        local owner
        owner="$(echo "$owner_repo" | cut -d'/' -f1)"
        echo ""
        echo "Your site will be live at https://${owner}.github.io/${repo_name}/ in about 60 seconds!"
    else
        echo "--- Manual Setup Instructions ---"
        echo ""
        echo "Since the GitHub CLI is not installed, follow these steps:"
        echo ""
        echo "  1. Create a new repository on GitHub named: ${repo_name}"
        echo "  2. Run these commands:"
        echo ""
        echo "     git remote add origin https://github.com/YOUR_USERNAME/${repo_name}.git"
        echo "     git branch -M main"
        echo "     git push -u origin main"
        echo ""
        echo "  3. Go to Settings > Pages and set Source to 'GitHub Actions'"
        echo ""
    fi

    # --- What's next ---
    echo ""
    echo "=== What's Next ==="
    echo ""
    echo "  1. Check the setup checklist issue in your repo's Issues tab"
    echo "  2. Replace the placeholder author photo in static/images/"
    echo "  3. Edit data/books.yaml with your real books"
    echo "  4. Update data/site.yaml with your full bio and social links"
    echo "  5. Push your changes and watch your site go live!"
    echo ""
    echo "Happy writing!"
    echo ""
}

# Guard: only run main when executed directly (not when sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
