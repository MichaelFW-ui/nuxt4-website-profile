# Nuxt Research Hub

A Nuxt 4 scaffold that blends a blog, paper repository, paper homepages, resume, and personal apps in one coherent structure using Nuxt UI + Nuxt Content.

## Architecture

- `app/pages/` contains view routes for each section.
- `content/` stores Markdown sources for blog posts, papers, apps, and static pages.
- `content.config.ts` defines collections and front matter schema for each section.
- `app/components/` provides shared layout blocks (hero, grid, header, footer).
- `app/assets/css/main.css` defines the visual system and layout styles.

## Content structure

```
content/
  index.md              # landing page narrative
  resume.md             # resume content
  research/index.md     # research homepage
  blog/*.md             # blog posts
  papers/*.md           # papers (public release + homepage)
  apps/*.md             # personal apps / demos
```

## Front matter fields

Blog posts (`content/blog/*.md`)
- `title`, `description`, `date`, `tags`, `readingTime`

Papers (`content/papers/*.md`)
- `title`, `summary`, `year`, `venue`, `status`, `authors`, `links`, `highlights`

Apps (`content/apps/*.md`)
- `title`, `summary`, `date`, `status`, `stack`, `links`, `goal`

## Commands

```
npm install
npm run dev
```
