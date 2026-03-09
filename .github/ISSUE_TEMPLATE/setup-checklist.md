---
name: Set Up Your Author Site
about: Follow this checklist to personalize your new website
title: "Set up my author site"
labels: setup
---

# Welcome to your new author website!

Follow these steps to make it yours. Check each box as you go.
Your site rebuilds automatically every time you save a file (give it about 60 seconds to update).

## Step 1: Enable GitHub Pages

- [ ] Go to your repo's **Settings** tab (top of the page)
- [ ] Click **Pages** in the left sidebar
- [ ] Under "Build and deployment", set **Source** to **GitHub Actions**
- [ ] That's it — no other Pages settings need to change

## Step 2: Pick your theme

- [ ] Open `config.yaml` (click the pencil icon to edit)
- [ ] Find the line that says `theme: "inkwell"`
- [ ] Change it to one of the themes below:
  - `inkwell` — Clean and literary, lots of white space, serif fonts
  - `paperback` — Bold and commercial, book covers front-and-center
  - `typewriter` — Retro and dark, monospace fonts, vintage feel
  - `mandatory-fun` — Bold and playful, geometric accents, purple and coral palette
- [ ] Update `title:` to your name or site name (this shows in browser tabs)
- [ ] Update `description:` under `params:` to a short description of your site (this shows in search results)
- [ ] Click "Commit changes" at the bottom

## Step 3: Upload your images

- [ ] Click on the `static/images/` folder
- [ ] Click "Add file" -> "Upload files"
- [ ] Upload your author photo and book cover images (any format: `.jpg`, `.png`, `.webp`, etc.)
- [ ] **Tip:** Avoid spaces in filenames — use dashes instead (e.g. `my-book-cover.jpg` not `my book cover.jpg`)
- [ ] Click "Commit changes"
- [ ] Note the exact filenames including extensions — you'll need them in the next steps

## Step 4: Add your information

- [ ] Open `data/site.yaml` (click the pencil icon to edit)
- [ ] Replace `Jane Author` with your name
- [ ] Replace the tagline with your own
- [ ] Replace the bio with your own (a few sentences about you)
- [ ] Update the `photo:` line to match your uploaded filename (e.g. `images/headshot.png`)
- [ ] Update the social media links (delete any you don't use)
- [ ] Update the contact email
- [ ] Click "Commit changes"

## Step 5: Add your books

- [ ] Open `data/books.yaml` (click the pencil icon to edit)
- [ ] Replace the example books with your own
- [ ] For each book, fill in: title, tagline, description, published year
- [ ] Update each `cover:` path to match your uploaded filename (e.g. `images/my-book-cover.jpg`)
- [ ] Add your buy links (Amazon, Bookshop.org, etc.)
- [ ] Set `featured: true` on the ONE book you want on your home page
- [ ] Click "Commit changes"

## Step 6: Check your site!

- [ ] Go to **Settings > Pages** — your live URL is shown at the top of the page
- [ ] Click the URL to visit your site (it may take a minute for the first build)
- [ ] If the page looks wrong, make sure you completed Step 1 (Source set to "GitHub Actions")

## Need help?

If something isn't working, open a new issue and describe what you see. We're happy to help!
