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

echo "[1/5] Build (local)"
pnpm install --frozen-lockfile
pnpm build

echo "[2/5] Pull repo on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'if git -C \"${VPS_APP_DIR}\" rev-parse --is-inside-work-tree >/dev/null 2>&1; then git -C \"${VPS_APP_DIR}\" fetch --prune && git -C \"${VPS_APP_DIR}\" pull --ff-only; else echo \"Missing git repo at ${VPS_APP_DIR}\"; exit 1; fi'"

echo "[3/5] Install deps on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'if git -C \"${VPS_APP_DIR}\" rev-parse --is-inside-work-tree >/dev/null 2>&1; then cd \"${VPS_APP_DIR}\" && pnpm install --frozen-lockfile; else echo \"Missing git repo at ${VPS_APP_DIR}\"; exit 1; fi'"

echo "[4/5] Rsync .output -> VPS"
rsync -az --delete \
  -e "ssh -p ${SSH_PORT}" \
  .output/ \
  "${SSH_TARGET}:${VPS_APP_DIR}/.output/"

echo "[5/5] Reload pm2 on VPS"
ssh -p "${SSH_PORT}" "${SSH_TARGET}" "bash -lc 'cd \"${VPS_APP_DIR}\" && pm2 reload \"${APP_NAME}\" || pm2 start ecosystem.config.cjs && pm2 save'"

echo "[6/6] Done"
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
