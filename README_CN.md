# Nuxt Research Hub

英文版: `README.md` | 中文版: `README_CN.md`

一个 Nuxt 4 脚手架，将博客、论文库、论文主页、简历和个人应用整合在同一结构中，基于 Nuxt UI + Nuxt Content。

## 架构

- `app/pages/` 存放各板块的页面路由。
- `content/` 存放博客、论文、应用与静态页的 Markdown 源文件。
- `content.config.ts` 定义各板块的集合与 front matter schema。
- `app/components/` 提供共享的布局组件（hero、grid、header、footer）。
- `app/assets/css/main.css` 定义视觉体系与布局样式。

## 内容结构

```
content/
  index.md              # 首页叙述
  resume.md             # 简历内容
  research/index.md     # 研究主页
  blog/*.md             # 博客文章
  papers/*.md           # 论文（公开发布 + 主页）
  apps/*.md             # 个人应用 / 演示
```

## Front matter 字段

博客文章（`content/blog/*.md`）
- `title`, `description`, `date`, `updated`, `tags`, `readingTime`

论文（`content/papers/*.md`）
- `title`, `summary`, `year`, `venue`, `status`, `authors`, `links`, `highlights`

应用（`content/apps/*.md`）
- `title`, `summary`, `date`, `status`, `stack`, `links`, `goal`

## 本地开发

```
pnpm install
pnpm dev
```

## 本地覆盖（不提交）

- `nuxt.app.config.local.ts` 用于覆盖 `app` 配置（标题/Meta/字体链接）。
- `nuxt.config.local.ts` 可覆盖任意 Nuxt 配置。

## 文章元数据自动化

`scripts/refresh-posts.sh` 会更新博客 front matter：
- 保留 `date`（创建日期），缺失时自动补齐
- 更新 `updated`（最后编辑日期）
- 重新计算 `readingTime`

只输入标题创建新文章：

```bash
bash scripts/refresh-posts.sh new "我的新文章"
```

刷新所有文章：

```bash
bash scripts/refresh-posts.sh
```

## 分支流程（模板 vs 私有内容）

- `main` 是公开模板分支。
- `md` 是私有内容分支，禁止推送。
- 除 `content/` 外的所有改动需要在 `md` 与 `main` 之间保持一致。

安装本地 push 保护（pre-push hook）：

```bash
bash scripts/install-hooks.sh
```

在 `md` 更新依赖，然后同步到 `main`：

```bash
git checkout md
pnpm update
git commit -am "chore(deps): update"

bash scripts/sync-deps.sh
git push origin main
```

`scripts/sync-deps.sh` 会把 `md` 分支的所有非 `content/` 变更快照到 `main`，并生成一次同步提交。

## 部署（私有）

部署从私有的 `md` 分支构建，并将 `.output` 同步到 VPS。
部署脚本位于 `.local/deploy.sh`（不提交）。

预期流程：
- 本地：`pnpm install --frozen-lockfile`，`pnpm build`
- 远端（若仓库存在）：`git pull`，`pnpm install --frozen-lockfile`
- 同步：`rsync .output`
- 重启：`pm2 reload`

脚本会强制本地构建必须在 `md` 分支执行。

示例脚本（使用占位值，真实脚本放在 `.local/deploy.sh`）：

```bash
#!/usr/bin/env bash
set -euo pipefail

# ====== 修改这里 ======
VPS_USER="your-user"            # 或者 ubuntu / deploy
VPS_HOST="your-host"            # VPS IP 或域名
VPS_SSH_HOST="your-ssh-alias"   # ssh 别名或 user@host；非空则覆盖 VPS_USER/VPS_HOST
VPS_APP_DIR="/var/www/nuxt-app/current"
APP_NAME="nuxt-app"
SSH_PORT="22"
BUILD_BRANCH="md"
# ======================

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

PM2 示例（`ecosystem.config.cjs`）：

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
