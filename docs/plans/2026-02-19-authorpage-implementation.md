# AuthorPage Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Hugo-based GitHub template repo that gives fiction authors a personal website in minutes with three custom themes, a CLI setup script, and a browser-only onboarding path.

**Architecture:** Hugo static site with data-driven content (YAML for books/site config, markdown for blog posts). Three self-contained themes following a shared contract. GitHub Actions for auto-deploy to GitHub Pages. A bash setup script for the CLI path and a GitHub Issue template for the non-technical path.

**Tech Stack:** Hugo (static site generator), HTML/CSS (no JS frameworks), Bash, GitHub Actions, GitHub CLI (`gh`)

---

### Task 1: Project Foundation — Hugo Config, Data Files, Content Pages

**Files:**
- Create: `config.yaml`
- Create: `data/site.yaml`
- Create: `data/books.yaml`
- Create: `content/_index.md`
- Create: `content/about.md`
- Create: `content/books.md`
- Create: `content/contact.md`
- Create: `content/blog/_index.md`
- Create: `content/blog/my-first-post.md`
- Create: `static/images/.gitkeep`

**Step 1: Create Hugo site config**

Create `config.yaml`:
```yaml
# ABOUTME: Main Hugo configuration file for the author website.
# ABOUTME: Controls site-wide settings, theme selection, and menu structure.

baseURL: "https://example.github.io/my-author-site/"
languageCode: "en-us"
title: "Author Site"
theme: "inkwell"

# Disable default Hugo features we don't need
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
```

**Step 2: Create data files with inline comments**

Create `data/site.yaml`:
```yaml
# ABOUTME: Author profile and site-wide information.
# ABOUTME: Edit this file to personalize your website.

# Your full name as you want it displayed on the site
name: "Jane Author"

# A short tagline shown under your name on the home page
tagline: "Author of The Midnight Garden"

# Your author bio — shown on the About page
bio: "Jane writes literary fiction exploring memory, place, and the stories we tell ourselves. She lives in Portland, Oregon with two cats and an unreasonable number of houseplants."

# Path to your author photo (upload the image to static/images/)
photo: "/images/author.jpg"

# Your social media links (delete any you don't use)
social:
  twitter: "https://twitter.com/janeauthor"
  instagram: "https://instagram.com/janeauthor"
  goodreads: "https://goodreads.com/janeauthor"

# Email address shown on the Contact page
contact_email: "jane@example.com"
```

Create `data/books.yaml`:
```yaml
# ABOUTME: Your book catalog displayed on the Books page and home page.
# ABOUTME: Add a new book by copying a block below and changing the values.

# To add a new book, copy everything from the dash (-) to the next dash
# and fill in your book's details. Newest books should go at the top.

- title: "The Midnight Garden"
  # Path to your book cover image (upload to static/images/)
  cover: "/images/midnight-garden.jpg"
  # One-line hook for your book
  tagline: "A novel about memory and forgetting"
  # A short description (2-3 sentences work best)
  description: "When Clara returns to her grandmother's house after twenty years, she discovers a garden that blooms only at night — and a family secret buried beneath its roots."
  # Year of publication
  published: 2024
  # Links where readers can buy your book (add as many as you like)
  buy_links:
    - label: "Amazon"
      url: "https://amazon.com/dp/your-book-id"
    - label: "Bookshop.org"
      url: "https://bookshop.org/p/books/your-book-id"
    - label: "Barnes & Noble"
      url: "https://barnesandnoble.com/w/your-book-id"
  # Set to true for ONE book to feature it on the home page
  featured: true

- title: "Letters from the Peninsula"
  cover: "/images/letters-peninsula.jpg"
  tagline: "A story of distance and devotion"
  description: "An epistolary novel spanning three decades of correspondence between two friends separated by an ocean."
  published: 2021
  buy_links:
    - label: "Amazon"
      url: "https://amazon.com/dp/your-book-id"
    - label: "Bookshop.org"
      url: "https://bookshop.org/p/books/your-book-id"
  featured: false
```

**Step 3: Create content pages**

Create `content/_index.md`:
```markdown
---
title: "Home"
---
```

Create `content/about.md`:
```markdown
---
title: "About"
layout: "about"
---
```

Create `content/books.md`:
```markdown
---
title: "Books"
layout: "books"
---
```

Create `content/contact.md`:
```markdown
---
title: "Contact"
layout: "contact"
---
```

Create `content/blog/_index.md`:
```markdown
---
title: "Blog"
---
```

Create `content/blog/my-first-post.md`:
```markdown
---
title: "Welcome to My Author Site"
date: 2024-01-15
description: "My first blog post — and a quick guide to writing more."
---

Welcome to my brand new author website! I'm excited to have a home on the web where I can share updates about my writing, upcoming releases, and the occasional behind-the-scenes look at my creative process.

## How to Write a New Blog Post

If you're reading this as the site owner, here's how to add your own posts:

1. Create a new file in the `content/blog/` folder
2. Name it something like `my-post-title.md`
3. Add the front matter at the top (the part between the `---` lines) with a title and date
4. Write your post in Markdown below the front matter
5. Commit the file — your site will update automatically!

That's it. Happy writing!
```

Create `static/images/.gitkeep` (empty file to ensure the directory exists in git).

**Step 4: Commit**

```bash
git add config.yaml data/ content/ static/
git commit -m "feat: add Hugo project foundation — config, data files, content pages"
```

---

### Task 2: Theme Contract Documentation & Manifests

**Files:**
- Create: `themes/README.md`
- Create: `themes/inkwell/theme.yaml`
- Create: `themes/paperback/theme.yaml`
- Create: `themes/typewriter/theme.yaml`

**Step 1: Write the theme contract doc**

Create `themes/README.md`:
```markdown
# ABOUTME: Documentation for the AuthorPage theme contract.
# ABOUTME: Read this before creating or modifying themes.

# AuthorPage Theme Contract

Every theme in this directory must implement the same set of layouts and partials so that swapping themes never breaks content.

## Required Directory Structure

```
themes/your-theme-name/
├── theme.yaml                          # Theme manifest
├── layouts/
│   ├── _default/
│   │   ├── baseof.html                 # Base template (HTML skeleton)
│   │   ├── list.html                   # List pages (blog index)
│   │   └── single.html                 # Single pages (blog posts)
│   ├── index.html                      # Home page
│   ├── page/
│   │   ├── about.html                  # About page layout
│   │   ├── books.html                  # Books listing layout
│   │   └── contact.html                # Contact page layout
│   └── partials/
│       ├── head.html                   # <head> contents (meta, CSS)
│       ├── header.html                 # Site header / navigation
│       ├── footer.html                 # Site footer
│       ├── hero.html                   # Home page hero section
│       ├── book-card.html              # Single book display card
│       └── post-list.html              # Blog post list item
└── assets/
    └── css/
        └── style.css                   # Theme stylesheet
```

## Theme Manifest (theme.yaml)

```yaml
name: "Your Theme Name"
description: "A short description of the theme's aesthetic"
preview: "/images/themes/your-theme-preview.png"
colors:
  primary: "#hex"
  background: "#hex"
  text: "#hex"
```

## Data File Expectations

Themes read from these data files (both are optional — templates must handle missing data gracefully):

- `data/site.yaml` — Author name, bio, tagline, photo, social links, contact email
- `data/books.yaml` — List of books with title, cover, tagline, description, published year, buy_links, featured flag

## Template Variables Available

All templates receive Hugo's standard page context. Data files are accessed via:
- `site.Data.site` — contents of `data/site.yaml`
- `site.Data.books` — contents of `data/books.yaml`
- `site.Menus.main` — navigation menu items from `config.yaml`

## Adding a New Theme

1. Create a new folder: `themes/your-theme-name/`
2. Copy the directory structure above
3. Implement all required layouts and partials
4. Add a `theme.yaml` manifest
5. Test: run `hugo server -t your-theme-name` and verify all five pages render
6. The setup script auto-discovers themes from `themes/*/theme.yaml`
```

**Step 2: Create theme manifests**

Create `themes/inkwell/theme.yaml`:
```yaml
name: "Inkwell"
description: "Minimal and literary — white space, serif typography, muted palette"
preview: "/images/themes/inkwell-preview.png"
colors:
  primary: "#2c3e50"
  background: "#faf9f6"
  text: "#333333"
  accent: "#8b7355"
```

Create `themes/paperback/theme.yaml`:
```yaml
name: "Paperback"
description: "Bold and commercial — book covers front-and-center, warm and inviting"
preview: "/images/themes/paperback-preview.png"
colors:
  primary: "#c0392b"
  background: "#ffffff"
  text: "#2d2d2d"
  accent: "#e67e22"
```

Create `themes/typewriter/theme.yaml`:
```yaml
name: "Typewriter"
description: "Retro and textured — monospace accents, dark mode, vintage personality"
preview: "/images/themes/typewriter-preview.png"
colors:
  primary: "#e8d5b7"
  background: "#1a1a2e"
  text: "#e0e0e0"
  accent: "#d4a574"
```

**Step 3: Commit**

```bash
git add themes/
git commit -m "feat: add theme contract documentation and theme manifests"
```

---

### Task 3: Inkwell Theme

**Files:**
- Create: `themes/inkwell/layouts/_default/baseof.html`
- Create: `themes/inkwell/layouts/_default/list.html`
- Create: `themes/inkwell/layouts/_default/single.html`
- Create: `themes/inkwell/layouts/index.html`
- Create: `themes/inkwell/layouts/page/about.html`
- Create: `themes/inkwell/layouts/page/books.html`
- Create: `themes/inkwell/layouts/page/contact.html`
- Create: `themes/inkwell/layouts/partials/head.html`
- Create: `themes/inkwell/layouts/partials/header.html`
- Create: `themes/inkwell/layouts/partials/footer.html`
- Create: `themes/inkwell/layouts/partials/hero.html`
- Create: `themes/inkwell/layouts/partials/book-card.html`
- Create: `themes/inkwell/layouts/partials/post-list.html`
- Create: `themes/inkwell/assets/css/style.css`

**Design direction:** Minimal, literary, lots of white space. Serif fonts (system serif stack). Muted warm palette (#faf9f6 background, #2c3e50 primary, #8b7355 accent). Thin borders, generous padding, elegant typography. Think independent bookstore meets gallery.

**Step 1: Create base template (`baseof.html`)**

The HTML skeleton. Links the CSS via Hugo's asset pipeline. Includes head, header, main content block, and footer partials.

```go-html-template
{{/* ABOUTME: Base HTML template for the Inkwell theme. */}}
{{/* ABOUTME: Provides the document skeleton that all pages extend. */}}
<!DOCTYPE html>
<html lang="{{ site.Language.LanguageCode | default "en" }}">
<head>
  {{ partial "head.html" . }}
</head>
<body>
  {{ partial "header.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
  {{ partial "footer.html" . }}
</body>
</html>
```

**Step 2: Create all partials**

`partials/head.html` — Meta tags, page title, CSS link using Hugo Pipes (`resources.Get`).

`partials/header.html` — Site name from `site.Data.site.name`, navigation from `site.Menus.main`. Clean horizontal nav with underline hover effects.

`partials/footer.html` — Copyright with author name and year. Social links from `site.Data.site.social`.

`partials/hero.html` — Author photo, name, tagline, and featured book (first book in `site.Data.books` where `.featured` is true). Used on the home page.

`partials/book-card.html` — Receives a single book context (`.`). Displays cover image, title, tagline, and buy links. Card layout with subtle shadow.

`partials/post-list.html` — Receives a page context. Displays title, date, and description/summary. Minimal list style.

**Step 3: Create page layouts**

`index.html` — Home page. Calls `hero.html` partial, then shows latest blog posts (3 most recent).

`page/about.html` — Renders author photo, bio from `site.Data.site`, and social links.

`page/books.html` — Iterates `site.Data.books`, calls `book-card.html` for each.

`page/contact.html` — Shows contact email and social links from `site.Data.site`.

`_default/list.html` — Blog index. Iterates `.Pages`, calls `post-list.html` for each.

`_default/single.html` — Blog post. Title, date, content.

**Step 4: Create stylesheet (`assets/css/style.css`)**

Inkwell aesthetic:
- System serif font stack: `Georgia, 'Times New Roman', serif`
- Background: `#faf9f6` (warm off-white)
- Text: `#333333`
- Primary: `#2c3e50` (dark blue-gray for headings/nav)
- Accent: `#8b7355` (warm brown for links/highlights)
- Max content width: `740px`, centered
- Generous `line-height: 1.8` for body text
- Thin `1px solid #e0dcd4` borders
- Subtle card shadows: `0 1px 3px rgba(0,0,0,0.08)`
- Navigation: horizontal, uppercase small letters, spaced tracking
- Responsive: single breakpoint at `768px`

**Step 5: Verify Hugo builds with Inkwell theme**

```bash
hugo --theme inkwell --buildDrafts 2>&1
```

Expected: Build succeeds, outputs to `public/` with pages for home, about, books, contact, blog, and the example post.

**Step 6: Commit**

```bash
git add themes/inkwell/
git commit -m "feat: add Inkwell theme — minimal literary aesthetic"
```

---

### Task 4: Paperback Theme

**Files:** Same layout structure as Inkwell, under `themes/paperback/`.

**Design direction:** Bold, commercial, warm. Sans-serif font stack (system). Book covers are the star — large, centered, with hover effects. Hero section has a gradient overlay. Colors: `#ffffff` background, `#c0392b` primary (rich red), `#e67e22` accent (warm orange). Bigger type, bolder weights, more visual punch. Think bestseller marketing page.

**Step 1: Create all layouts and partials**

Same template contract as Inkwell but with Paperback-specific markup and classes where needed for different visual layouts (e.g., book cards might be larger with more prominent cover images, hero might have a gradient backdrop).

**Step 2: Create stylesheet (`assets/css/style.css`)**

Paperback aesthetic:
- System sans-serif stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
- Background: `#ffffff`
- Text: `#2d2d2d`
- Primary: `#c0392b` (rich red for headings, CTAs)
- Accent: `#e67e22` (warm orange for highlights, hover)
- Max content width: `960px`, centered
- Hero: full-width section with subtle gradient background
- Book cards: larger cover images (300px+), shadow on hover, buy buttons styled as CTA pills
- Navigation: bold weight, colored underline on active
- Responsive: breakpoints at `768px` and `480px`

**Step 3: Verify Hugo builds**

```bash
hugo --theme paperback --buildDrafts 2>&1
```

**Step 4: Commit**

```bash
git add themes/paperback/
git commit -m "feat: add Paperback theme — bold commercial aesthetic"
```

---

### Task 5: Typewriter Theme

**Files:** Same layout structure as Inkwell, under `themes/typewriter/`.

**Design direction:** Retro, dark, textured. Monospace font stack. Dark background (`#1a1a2e`) with warm light text (`#e0e0e0`). Accent color `#d4a574` (aged parchment). Subtle noise texture via CSS. Think vintage typewriter ribbon meets noir film poster.

**Step 1: Create all layouts and partials**

Same template contract. Typewriter-specific touches: monospace nav, ASCII-style decorative dividers, slightly rougher presentation.

**Step 2: Create stylesheet (`assets/css/style.css`)**

Typewriter aesthetic:
- Monospace stack: `'Courier New', Courier, 'Liberation Mono', monospace`
- Background: `#1a1a2e` (deep navy-black)
- Text: `#e0e0e0` (soft white)
- Primary: `#e8d5b7` (warm parchment)
- Accent: `#d4a574` (aged copper)
- Max content width: `700px`, centered
- Subtle text-shadow on headings for typewriter "strike" effect
- Navigation: monospace, `>` character prefix on hover
- Book cards: bordered with dashed lines, cover images with slight sepia filter
- Blog posts: indented paragraphs, typewriter-style blockquotes
- Responsive: breakpoints at `768px` and `480px`

**Step 3: Verify Hugo builds**

```bash
hugo --theme typewriter --buildDrafts 2>&1
```

**Step 4: Commit**

```bash
git add themes/typewriter/
git commit -m "feat: add Typewriter theme — retro dark aesthetic"
```

---

### Task 6: GitHub Actions Deploy Workflow

**Files:**
- Create: `.github/workflows/deploy.yml`

**Step 1: Create the workflow file**

```yaml
# ABOUTME: GitHub Actions workflow to build and deploy the Hugo site to GitHub Pages.
# ABOUTME: Triggers automatically on every push to the main branch.

name: Deploy Hugo site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

defaults:
  run:
    shell: bash

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.141.0
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5
      - name: Build with Hugo
        env:
          HUGO_CACHEDIR: ${{ runner.temp }}/hugo_cache
          HUGO_ENVIRONMENT: production
        run: |
          hugo \
            --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/"
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**Step 2: Commit**

```bash
git add .github/
git commit -m "feat: add GitHub Actions workflow for Pages deployment"
```

---

### Task 7: GitHub Issue Template — Setup Wizard

**Files:**
- Create: `.github/ISSUE_TEMPLATE/setup-checklist.md`

**Step 1: Create the issue template**

The checklist should:
- Use clear, friendly language for non-technical authors
- Link directly to files they need to edit (using relative GitHub URLs)
- Include before/after examples for each edit
- Auto-discover theme names is not possible in an issue template, so list the three themes by name (this is the one place we hardcode them — acceptable tradeoff for the non-technical path)

```markdown
---
name: Set Up Your Author Site
about: Follow this checklist to personalize your new website
title: "Set up my author site"
labels: setup
---

# Welcome to your new author website!

Follow these steps to make it yours. Check each box as you go.
Your site rebuilds automatically every time you save a file (give it about 60 seconds to update).

## Step 1: Pick your theme

- [ ] Open `config.yaml` (click the pencil icon to edit)
- [ ] Find the line that says `theme: "inkwell"`
- [ ] Change it to one of: `inkwell`, `paperback`, or `typewriter`
  - **Inkwell** — Clean and literary, lots of white space, serif fonts
  - **Paperback** — Bold and commercial, book covers front-and-center
  - **Typewriter** — Retro and dark, monospace fonts, vintage feel
- [ ] Click "Commit changes" at the bottom

## Step 2: Add your information

- [ ] Open `data/site.yaml` (click the pencil icon to edit)
- [ ] Replace `Jane Author` with your name
- [ ] Replace the tagline with your own
- [ ] Replace the bio with your own (a few sentences about you)
- [ ] Update the social media links (delete any you don't use)
- [ ] Update the contact email
- [ ] Click "Commit changes"

## Step 3: Add your author photo

- [ ] Click on the `static/images/` folder
- [ ] Click "Add file" → "Upload files"
- [ ] Upload your author photo and name it `author.jpg`
- [ ] Click "Commit changes"

## Step 4: Add your books

- [ ] Open `data/books.yaml` (click the pencil icon to edit)
- [ ] Replace the example books with your own
- [ ] For each book, fill in: title, tagline, description, published year
- [ ] Upload cover images to `static/images/` (same process as your photo)
- [ ] Update the `cover:` path to match your image filename
- [ ] Add your buy links (Amazon, Bookshop.org, etc.)
- [ ] Set `featured: true` on the ONE book you want on your home page
- [ ] Click "Commit changes"

## Step 5: Check your site!

- [ ] Visit `https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/`
- [ ] It may take a minute for the first build to complete
- [ ] If you see a 404, go to Settings → Pages and make sure the Source is set to "GitHub Actions"

## Need help?

If something isn't working, open a new issue and describe what you see. We're happy to help!
```

**Step 2: Commit**

```bash
git add .github/ISSUE_TEMPLATE/
git commit -m "feat: add GitHub Issue setup checklist for non-technical onboarding"
```

---

### Task 8: Setup Script (`setup.sh`)

**Files:**
- Create: `setup.sh`
- Create: `tests/test_setup.sh`

**Step 1: Write tests for the setup script**

Create `tests/test_setup.sh` — a bash test script that:
- Tests theme auto-discovery (creates temp theme dirs, verifies script finds them)
- Tests config file generation (runs the config-writing function, verifies output)
- Tests `site.yaml` generation (verifies YAML output matches expected format)
- Tests graceful behavior when `gh` is not available
- Tests default values are applied when user provides empty input
- Uses a temp directory for all file operations, cleans up after

**Step 2: Run tests to verify they fail**

```bash
bash tests/test_setup.sh
```

Expected: FAIL (setup.sh doesn't exist yet)

**Step 3: Write `setup.sh`**

The script should:
1. Print a friendly welcome banner
2. Check for `git` (required) — exit with install instructions if missing
3. Check for `gh` (optional) — note it and continue if missing
4. Auto-discover themes by scanning `themes/*/theme.yaml`
5. Prompt for author name (default: "Author Name")
6. Prompt for tagline (default: "Writer of stories")
7. Display discovered themes with numbers, prompt for selection
8. Prompt for GitHub repo name (default: "my-author-site")
9. Write `config.yaml` with chosen theme
10. Write `data/site.yaml` with provided info
11. `git init` + `git add -A` + `git commit`
12. If `gh` is available: `gh repo create`, `git push`, enable Pages via `gh api`
13. Print the live URL and a "what's next" message
14. If `gh` is not available: print manual push instructions

Mark the file executable: `chmod +x setup.sh`

**Step 4: Run tests to verify they pass**

```bash
bash tests/test_setup.sh
```

Expected: All tests PASS

**Step 5: Commit**

```bash
git add setup.sh tests/
git commit -m "feat: add CLI setup script with theme auto-discovery"
```

---

### Task 9: README — The "Book Chapter" Guide

**Files:**
- Create: `README.md`

**Step 1: Write the README**

Structure:
1. **Hero section** — Project name, one-line pitch, screenshot/preview placeholders
2. **What is this?** — 2-3 sentences explaining what AuthorPage does
3. **Quick Start: I'm comfortable with a terminal** — Step-by-step CLI path instructions (clone, run setup.sh, done)
4. **Quick Start: I've never used GitHub** — Step-by-step browser path instructions (create account, use template, follow checklist)
5. **Choosing a Theme** — Visual description of each theme with personality
6. **Customizing Your Site** — How to edit `data/site.yaml`, `data/books.yaml`, add blog posts
7. **Adding a New Book** — Copy-paste-friendly example
8. **Writing a Blog Post** — Copy-paste-friendly example
9. **FAQ** — Common questions (custom domain, theme switching, local preview)
10. **For Developers: Adding a Theme** — Link to `themes/README.md`

The tone should be warm, encouraging, and assume zero technical knowledge for the browser path sections.

**Step 2: Commit**

```bash
git add README.md
git commit -m "feat: add README with complete setup guides for both paths"
```

---

### Task 10: Build Verification Tests

**Files:**
- Create: `tests/test_builds.sh`

**Step 1: Write Hugo build verification tests**

Create `tests/test_builds.sh`:
- For each theme (auto-discovered from `themes/*/theme.yaml`):
  - Build the site with that theme: `hugo --theme $theme --buildDrafts -d /tmp/authorpage-test-$theme`
  - Verify exit code is 0
  - Verify `index.html` exists in output
  - Verify `about/index.html` exists
  - Verify `books/index.html` exists
  - Verify `contact/index.html` exists
  - Verify `blog/index.html` exists
  - Verify blog post exists: `blog/my-first-post/index.html` (or similar slug)
  - Verify HTML contains author name from `data/site.yaml`
  - Verify HTML contains book title from `data/books.yaml`
  - Clean up temp directory
- Print summary: X themes tested, Y passed, Z failed

**Step 2: Run the build tests**

```bash
bash tests/test_builds.sh
```

Expected: All 3 themes build and pass all checks.

**Step 3: Commit**

```bash
git add tests/test_builds.sh
git commit -m "feat: add build verification tests for all themes"
```

---

### Task 11: Final Integration Verification

**Step 1: Run all tests**

```bash
bash tests/test_setup.sh && bash tests/test_builds.sh
```

Expected: All tests pass.

**Step 2: Test Hugo local server with each theme**

```bash
hugo server --theme inkwell --buildDrafts &
# verify http://localhost:1313 renders
kill %1
hugo server --theme paperback --buildDrafts &
# verify http://localhost:1313 renders
kill %1
hugo server --theme typewriter --buildDrafts &
# verify http://localhost:1313 renders
kill %1
```

**Step 3: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: address integration test findings"
```
