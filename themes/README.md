[//]: # "ABOUTME: Documentation for the AuthorPage theme contract."
[//]: # "ABOUTME: Read this before creating or modifying themes."

# AuthorPage Theme Contract

Every theme in this directory must implement the same set of layouts and partials so that swapping themes never breaks content.

## Required Directory Structure

````
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
````

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
- `hugo.Data.site` — contents of `data/site.yaml`
- `hugo.Data.books` — contents of `data/books.yaml`
- `site.Menus.main` — navigation menu items from `config.yaml`

## Adding a New Theme

1. Create a new folder: `themes/your-theme-name/`
2. Copy the directory structure above
3. Implement all required layouts and partials
4. Add a `theme.yaml` manifest
5. Test: run `hugo server -t your-theme-name` and verify all five pages render
6. The setup script auto-discovers themes from `themes/*/theme.yaml`
