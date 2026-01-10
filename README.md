# Nuxt Research Hub

English: `README.md` | Chinese: `README_CN.md`

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

## Local development

```
pnpm install
pnpm dev
```

## Branching workflow (template vs. private content)

- `main` is the public template branch.
- `md` is the private content branch and should never be pushed.
- Everything except `content/` should stay in sync between `md` and `main`.

Install local push guards (pre-push hook):

```bash
bash scripts/install-hooks.sh
```

Update dependencies on `md`, then sync to `main`:

```bash
git checkout md
pnpm update
git commit -am "chore(deps): update"

bash scripts/sync-deps.sh
git push origin main
```

`scripts/sync-deps.sh` snapshots all changes from `md` into `main` except `content/`, and makes a single sync commit.

## Deployment (private)

Deployment runs from the private `md` branch and syncs the built `.output` to the VPS.
The deploy script lives in `.local/deploy.sh` (not committed).

Expected flow:
- local: `pnpm install --frozen-lockfile`, `pnpm build`
- remote (if repo exists): `git pull`, `pnpm install --frozen-lockfile`
- sync: `rsync .output`
- restart: `pm2 reload`

The script enforces that the local build runs on `md`.
