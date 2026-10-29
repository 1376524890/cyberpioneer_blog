#!/usr/bin/env bash
# Cyber先锋社博客 - 备用部署脚本（自建服务器手动构建）
#
# ⚠ 日常部署已迁移至 Cloudflare Pages：push 到 main 即自动构建发布，
#    本脚本仅在 Cloudflare Pages 不可用等应急场景下使用。
#
# 用法：在备用服务器的仓库目录下执行 bash scripts/deploy.sh
# 流程：拉取最新源码 -> 安装依赖 -> 构建 -> 同步产物到站点目录
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="${WEB_DIR:-/var/www/cyber_blog}"

cd "$REPO_DIR"

echo "==> [1/4] 拉取最新代码..."
git fetch origin
git reset --hard origin/main

echo "==> [2/4] 安装依赖（有 lockfile 变更时较慢）..."
export NODE_OPTIONS="--max-old-space-size=1536"
pnpm install --frozen-lockfile

echo "==> [3/4] 构建静态站点..."
pnpm build

echo "==> [4/4] 同步到 $WEB_DIR ..."
rsync -a --delete "$REPO_DIR/dist/" "$WEB_DIR/"

echo "==> 部署完成！"
