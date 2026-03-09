# AuthorPage — Design Document

## Overview

A GitHub template repository that gives fiction authors a beautiful personal website in minutes, hosted free on GitHub Pages via Hugo.

## Two Paths to Get Started

### CLI Path
A single bash script (`setup.sh`) that asks your name, bio, and theme preference, then creates a GitHub repo, pushes everything, enables Pages, and prints your live URL. Requires `git` and `gh` CLI.

### Non-Technical Path
Click "Use This Template" on GitHub, follow a setup checklist delivered as a GitHub Issue, edit files through GitHub's web UI. Never touch a terminal.

## Three Custom Themes

- **Inkwell** — Minimal, literary, lots of white space, serif typography, muted palette. For literary fiction and poetry authors.
- **Paperback** — Bold, commercial, book covers front-and-center, hero section with latest release, newsletter-friendly. For genre fiction authors.
- **Typewriter** — Retro, monospace accents, dark mode default, textured feel. For horror, noir, or authors who want personality.

## Pages Included Out of the Box

- **Home** — Hero with author photo + tagline + latest/featured book
- **About** — Bio, photo, social links
- **Books** — Grid/list of books with covers, blurbs, buy links
- **Blog** — With one example post showing how it works
- **Contact** — Email + social links

## Project Structure

```
authorpage/
├── README.md                    # The "book chapter" guide
├── setup.sh                     # CLI setup script
├── .github/
│   ├── workflows/
│   │   └── deploy.yml           # Hugo build + GitHub Pages deploy
│   └── ISSUE_TEMPLATE/
│       └── setup-checklist.md   # Onboarding wizard issue
├── config.yaml                  # Hugo config (points to chosen theme)
├── data/
│   ├── site.yaml                # Author name, bio, tagline, social links
│   └── books.yaml               # Book catalog
├── content/
│   ├── _index.md                # Home page
│   ├── about.md                 # About page
│   ├── books.md                 # Books listing page
│   ├── contact.md               # Contact page
│   └── blog/
│       └── my-first-post.md     # Example blog post
├── static/
│   ├── images/                  # Author photo, book covers
│   └── favicon.ico
└── themes/
    ├── inkwell/
    ├── paperback/
    ├── typewriter/
    └── README.md                # Theme contract documentation
```

## Theme Architecture

Each theme is a self-contained directory under `themes/` following Hugo's standard theme contract.

### Theme Contract
- All themes implement identical partial names: `hero.html`, `book-card.html`, `post-list.html`, etc.
- All themes read from the same data files (`data/site.yaml`, `data/books.yaml`)
- Each theme has a `theme.yaml` manifest (name, description, preview image, color palette)
- Swapping themes never breaks content — themes are purely visual

### Adding a New Theme
1. Create a new folder in `themes/`
2. Implement the same set of Hugo layouts (partials, templates)
3. Add a `theme.yaml` manifest
4. The setup script and setup checklist auto-discover themes — no hardcoded list

## Content Model

### `data/site.yaml`
```yaml
name: "Jane Author"
tagline: "Author of The Midnight Garden"
bio: "Jane writes literary fiction from her home in Portland..."
photo: "/images/author.jpg"
social:
  twitter: "https://twitter.com/janeauthor"
  instagram: "https://instagram.com/janeauthor"
  goodreads: "https://goodreads.com/janeauthor"
contact_email: "jane@example.com"
```

### `data/books.yaml`
```yaml
- title: "The Midnight Garden"
  cover: "/images/midnight-garden.jpg"
  tagline: "A novel about memory and forgetting"
  description: "When Clara returns to her grandmother's house..."
  published: 2024
  buy_links:
    - label: "Amazon"
      url: "https://amazon.com/..."
    - label: "Bookshop.org"
      url: "https://bookshop.org/..."
  featured: true
```

### Blog Posts
Standard Hugo markdown in `content/blog/` with title and date front matter.

## Data Model Principles
- No nesting deeper than two levels
- Every field optional except `name` (site.yaml) and `title` (books.yaml)
- Inline comments in default YAML files explain every field
- Example blog post doubles as a tutorial

## CLI Flow (`setup.sh`)
1. Check `git` and `gh` are installed (friendly errors with install links)
2. Prompt: author name → `data/site.yaml`
3. Prompt: tagline → `data/site.yaml`
4. Prompt: pick a theme (auto-discovered from `themes/*/theme.yaml`)
5. Prompt: GitHub repo name (default: `my-author-site`)
6. Write `config.yaml` and `data/site.yaml`
7. Git init + initial commit
8. `gh repo create`, push, enable GitHub Pages
9. Print live URL
- Falls back gracefully if `gh` is not installed (skips repo creation)
- All prompts have sensible defaults

## Non-Technical Path
1. Click "Use this template" on GitHub
2. Open Issues tab → "Set Up Your Author Site" checklist
3. Checklist items link directly to files to edit, with before/after examples
4. GitHub Actions auto-deploys on every commit to `main`

## GitHub Actions Workflow
- Triggers on push to `main`
- Installs Hugo, builds site, deploys to GitHub Pages
- Zero configuration needed from the author
