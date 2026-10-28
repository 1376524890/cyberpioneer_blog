---
title: 本博客的诞生记录：Astro + Firefly 建站全流程
published: 2026-10-28
description: 记录 Cyber先锋社官方博客从框架选型到上线的完整过程：为什么选择 Astro + Firefly？静态博客如何部署？本文也是一份可复用的建站思路参考。
tags: [建站, Astro, 运维部署]
category: 技术分享
slug: how-this-blog-was-built
---

## 为什么选择静态博客

社团官网的核心需求很简单：**展示文章、稳定、省资源、好维护**。对比了几个方案：

| 方案 | 优点 | 缺点 |
| --- | --- | --- |
| WordPress | 生态大、后台完善 | PHP + MySQL，资源占用高，需要持续打补丁 |
| Halo | 国产、界面现代 | 需要 Java 运行时，内存占用高 |
| **Astro 静态站** | 零数据库、纯静态文件、速度快 | 更新内容需要重新构建 |

我们的服务器配置不高，静态方案几乎不占运行时资源，nginx 托管静态文件的内存开销可以忽略，安全性也远好于动态 CMS——最终选择 **Astro + Firefly 主题**。

## 技术栈一览

```text
博客框架     Astro v7（静态站点生成）
主题         Firefly（基于 Fuwari 二次开发）
包管理器     pnpm
源码托管     GitHub - 1376524890/cyberpioneer_blog
Web 服务     nginx（托管静态文件）
部署方式     源码推 GitHub → 服务器拉取构建 → 同步上线
```

## 本地开发流程

```bash
# 安装依赖（需要 Node.js >= 22.23）
corepack enable
pnpm install

# 本地预览 http://localhost:4321
pnpm dev

# 构建静态站点到 dist/
pnpm build
```

### 写一篇新文章

文章以 Markdown 格式存放在 `src/content/posts/` 目录，只需复制一份模板修改 frontmatter：

```markdown
---
title: 文章标题
published: 2026-10-28
description: 一句话摘要，会显示在列表页
tags: [标签1, 标签2]
category: 分类名
slug: url-friendly-slug
---

正文支持 Markdown……
```

保存后推送到 GitHub，服务器端拉取重新构建即可上线。

## 部署要点

静态博客的部署非常简单：任意一台 Linux 服务器 + nginx 托管 `dist/` 目录即可。下面是一份通用的 nginx 站点配置示例（端口与路径按自己环境调整）：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/blog;   # 指向构建产物目录
    index index.html;

    # Astro 默认带尾斜杠
    location / {
        try_files $uri $uri/ $uri/index.html =404;
    }

    # 静态资源长缓存
    location /_astro/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/css application/javascript image/svg+xml application/json;
}
```

我们的更新流程：源码推送到 GitHub 后，在服务器上拉取、构建，再把 `dist/` 同步到站点目录，一条脚本搞定。出于安全考虑，服务器的具体信息不在此公开。

## 一点心得

- 静态博客把安全面缩到最小：没有数据库、没有后台登录、没有插件供应链
- GitHub 管源码，服务器只管渲染结果，职责清晰
- 小内存机器跑 nginx + 静态文件毫无压力，轻松扛住校园级流量

---

*如果你也想给社团或自己搭一个博客，欢迎在群里交流，我们可以出一份保姆级教程。*
