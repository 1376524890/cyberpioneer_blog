# Cyber先锋社博客

Cyber先锋社官方网站与博客，基于 [Astro](https://astro.build) + [Firefly](https://github.com/CuteLeaf/Firefly) 主题构建。

- **线上地址**：https://www.cyberpioneer.club （Cloudflare Tunnel + nginx 81 端口回源）
- **源码仓库**：https://github.com/1376524890/cyberpioneer_blog
- **服务器**：阿里云 ECS（Ubuntu 22.04），站点目录 `/var/www/cyber_blog`

---

## 🚀 快速开始（本地开发）

### 环境要求

- Node.js `>= 22.23.0`（建议用 [nvm](https://github.com/nvm-sh/nvm) 管理）
- pnpm（`corepack enable` 即可自动激活）

### 本地运行

```bash
git clone git@github.com:1376524890/cyberpioneer_blog.git
cd cyberpioneer_blog
corepack enable        # 激活 pnpm
pnpm install           # 安装依赖
pnpm dev               # 本地预览 http://localhost:4321
pnpm build             # 构建静态站点到 dist/
```

## ✍️ 如何写文章（社团成员必读）

文章存放于 `src/content/posts/`，Markdown 格式，文件头部使用 frontmatter 定义元信息：

```markdown
---
title: 文章标题
published: 2026-10-28          # 发布日期
pinned: false                  # 是否置顶（可选）
description: 一句话摘要，显示在文章列表
tags: [标签1, 标签2]
category: 分类名
slug: url-friendly-slug        # URL 路径，英文短横线
---

正文内容，支持标准 Markdown……
```

### 写作规则

1. **文件命名**：与 `slug` 保持一致，如 `my-first-post.md`
2. **slug 规则**：只用小写英文、数字、短横线 `-`，避免中文和特殊字符
3. **分类（category）**：建议沿用现有分类（社团动态 / 技术分享），新增分类请先在群里商量
4. **标签（tags）**：3 个以内为宜，保持语义化
5. **图片**：放在文章同名目录 `src/content/posts/images/` 下，用相对路径引用
6. **内容红线**：涉及漏洞利用、渗透测试的内容**必须**限于合法靶场/授权测试场景，附免责说明；不发布真实攻击载荷、敏感信息（密码、内网拓扑等）
7. 提交前建议本地跑一遍 `pnpm build` 确认构建通过

### 也可以用脚手架

```bash
pnpm new-post    # 按提示生成文章模板
```

## 🔄 更新与部署流程

**本仓库是唯一维护入口：改代码/写文章 → push 到 main → 服务器拉取构建上线。**

### 标准流程（推荐）

1. 本地写好文章或改好配置
2. 提交并推送：

   ```bash
   git add .
   git commit -m "post: 新增XXX文章"
   git push origin main
   ```

3. SSH 到服务器执行一键部署：

   ```bash
   ssh root@8.152.200.16
   bash /opt/cyber_blog/scripts/deploy.sh
   ```

   脚本会自动完成：拉取代码 → 安装依赖 → 构建 → 同步到 `/var/www/cyber_blog`

### Commit 规范

沿用 Conventional Commits：

| 前缀 | 用途 |
| --- | --- |
| `post:` | 新增/修改文章 |
| `feat:` | 新功能 |
| `fix:` | 修复 |
| `docs:` | 文档变更 |
| `chore:` | 依赖、配置等杂项 |

## 🏗️ 站点架构速览

| 项目 | 说明 |
| --- | --- |
| 框架 | Astro v7（纯静态生成） |
| 主题 | [Firefly](https://github.com/CuteLeaf/Firefly)（MIT 协议，基于 Fuwari） |
| 站点配置 | `src/config/siteConfig.ts`（标题/描述/导航/页面开关） |
| 文章目录 | `src/content/posts/` |
| 关于页 | `src/content/spec/about.md` |
| 项目展示 | `src/content/projects/` |
| 动态（说说） | `src/content/dynamic/` |
| 字体 | 本地 woff2（`src/assets/fonts/`），不依赖外部 CDN |
| Web 服务 | nginx 监听 81 端口 |
| 外网接入 | Cloudflare Tunnel（`cloudflared` systemd 服务，token 模式） |

### 服务器常用命令

```bash
systemctl status cloudflared        # 隧道状态
systemctl reload nginx              # 改 nginx 配置后重载
tail -f /var/log/nginx/error.log    # nginx 错误日志
bash /opt/cyber_blog/scripts/deploy.sh   # 一键重新部署
```

## 📄 许可

- 站点主题 Firefly 遵循 [MIT License](./LICENSE)
- 文章内容版权归原作者所有，转载请联系社团
