#!/usr/bin/env bash
# Cyber先锋社博客 - 服务器端部署脚本
# 用法：在服务器 /opt/cyber_blog 下执行 bash scripts/deploy.sh
# 流程：拉取最新源码 -> 安装依赖 -> 构建 -> 同步产物到 nginx 目录
set -euo pipefail

REPO_DIR="/opt/cyber_blog"
WEB_DIR="/var/www/cyber_blog"

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

echo "==> 部署完成！访问 https://www.cyberpioneer.club 验证"
