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

## Images in Markdown content

- Store images in `public/` (recommended: `public/images/`) so Nuxt can serve them.
- Reference them in Markdown with absolute paths like `/images/001.png`.
- Markdown images are rendered by `app/components/content/ProseImg.vue` with `loading="lazy"`, `max-width: 100%`, and `width: 100%`.
- Use MDC attributes to style per image:

```md
![Centered half width](/images/001.png){.content-img--w-50 .content-img--center}
![Rounded](/images/001.png){.content-img--rounded}
![Square](/images/001.png){.content-img--square}
![Right aligned](/images/001.png){.content-img--w-33 .content-img--right}
![Eager load](/images/001.png){loading="eager"}
```

- Supported classes:
  - Alignment: `.content-img--center`, `.content-img--left`, `.content-img--right`
  - Width: `.content-img--w-25`, `.content-img--w-33`, `.content-img--w-50`, `.content-img--w-66`, `.content-img--w-75`, `.content-img--w-100`
  - Shape: `.content-img--rounded`, `.content-img--square`
- Inline styles are supported via MDC attributes, e.g. `{style="border-radius: 6px"}`.

## Math in Markdown

- Inline: `$E = mc^2$`
- Block:

```md
$$
\int_0^\infty e^{-x^2} \, dx = \frac{\sqrt{\pi}}{2}
$$
```

## Front matter fields

Blog posts (`content/blog/*.md`)
- `title`, `description`, `date`, `updated`, `tags`, `readingTime`

Papers (`content/papers/*.md`)
- `title`, `summary`, `year`, `venue`, `status`, `authors`, `links`, `highlights`

Apps (`content/apps/*.md`)
- `title`, `summary`, `date`, `status`, `stack`, `links`, `goal`

## Local development

```
pnpm install
pnpm dev
```

## Local overrides (not committed)

- `nuxt.app.config.local.ts` overrides `app` config (title/meta/links).
- `nuxt.config.local.ts` overrides any Nuxt config settings.

## Post metadata automation

`scripts/refresh-posts.sh` updates blog front matter:
- keeps `date` (creation date), adds it if missing
- updates `updated` (last edit date)
- recalculates `readingTime`

Create a new post with only a title:

```bash
bash scripts/refresh-posts.sh new "My New Post"
```

Refresh all posts:

```bash
bash scripts/refresh-posts.sh
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

Example script (use dummy values and keep the real one in `.local/deploy.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

# ====== edit here ======
VPS_USER="your-user"            # or ubuntu / deploy
VPS_HOST="your-host"            # VPS IP or domain
VPS_SSH_HOST="your-ssh-alias"   # ssh alias or user@host; if set, overrides VPS_USER/VPS_HOST
VPS_APP_DIR="/var/www/nuxt-app/current"
APP_NAME="nuxt-app"
SSH_PORT="22"
BUILD_BRANCH="md"
# =======================

SSH_TARGET="${VPS_SSH_HOST:-}"
if [ -z "$SSH_TARGET" ]; then
  SSH_TARGET="${VPS_USER}@${VPS_HOST}"
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" != "$BUILD_BRANCH" ]; then
  echo "Build must run on '${BUILD_BRANCH}' branch (current: ${CURRENT_BRANCH})." >&2
  exit 1
fi

echo "[1/6] Refresh post metadata"
bash scripts/refresh-posts.sh

echo "[2/6] Build (local)"
pnpm install --frozen-lockfile
pnpm build

echo "[3/6] Pull repo on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'if git -C \"${VPS_APP_DIR}\" rev-parse --is-inside-work-tree >/dev/null 2>&1; then git -C \"${VPS_APP_DIR}\" fetch --prune && git -C \"${VPS_APP_DIR}\" pull --ff-only; else echo \"Missing git repo at ${VPS_APP_DIR}\"; exit 1; fi'"

echo "[4/6] Install deps on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'if git -C \"${VPS_APP_DIR}\" rev-parse --is-inside-work-tree >/dev/null 2>&1; then cd \"${VPS_APP_DIR}\" && pnpm install --frozen-lockfile; else echo \"Missing git repo at ${VPS_APP_DIR}\"; exit 1; fi'"

echo "[5/6] Rsync .output -> VPS"
rsync -az --delete \
  -e "ssh -p ${SSH_PORT}" \
  .output/ \
  "${SSH_TARGET}:${VPS_APP_DIR}/.output/"

echo "[6/6] Reload pm2 on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'cd \"${VPS_APP_DIR}\" && pm2 reload \"${APP_NAME}\" || pm2 start ecosystem.config.cjs && pm2 save'"

echo "Done"
```

PM2 example (`ecosystem.config.cjs`):

```js
module.exports = {
  apps: [
    {
      name: "nuxt-app",
      script: ".output/server/index.mjs",
      exec_interpreter: "node",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "400M",
      env: {
        NODE_ENV: "production",
        PORT: 3000
      }
    }
  ]
};
```
