# Cyber先锋社博客 · 成员手册

Cyber先锋社官方网站与博客，基于 [Astro](https://astro.build) + [Firefly](https://github.com/CuteLeaf/Firefly) 主题构建。

- **线上地址**：https://www.cyberpioneer.club
- **源码仓库**：https://github.com/1376524890/cyberpioneer_blog

> 本 README 即**新成员手册**：完整覆盖全部板块的定位、内容、更新方法与注意事项，读完即可独立完成日常更新与维护。

## 📑 目录索引

- [快速上手](#一快速上手)——环境搭建与发布流程
- [板块指南](#二板块指南)——12 个板块逐一说明
- [站点架构速览](#三站点架构速览)
- [常见问题与维护节奏](#四常见问题与维护节奏)
- [许可](#五许可)

**配套文档**：[docs/tutorial-rules.md](./docs/tutorial-rules.md)（教程写作规范）｜[docs/image-prompts.md](./docs/image-prompts.md)（配图风格与 AI 提示词）

---

## 一、快速上手

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

### 更新发布的完整流程（所有板块通用）

**总原则：push 到 main → Cloudflare Pages 自动构建发布，通常 1-2 分钟后线上生效，无需任何手动部署。**

```bash
# ① 本地修改（写文章 / 改配置 / 加图片）
# ② 本地验证（可选但推荐）
pnpm dev               # 预览检查排版

# ③ 提交推送
git add .
git commit -m "post: 写清楚你改了什么"
git push origin main

# ④ 等待 1-2 分钟自动上线
#    浏览器强制刷新（Ctrl/Cmd+Shift+R）查看最新版本
```

> 没配本地环境也能更新：直接在 GitHub 网页上编辑文件（铅笔图标）→ Commit changes，同样触发自动构建。适合改错字、发短动态这类轻量操作。

### Commit 规范

沿用 Conventional Commits：

| 前缀 | 用途 |
| --- | --- |
| `post:` | 新增/修改文章 |
| `feat:` | 新功能 |
| `fix:` | 修复 |
| `docs:` | 文档变更 |
| `chore:` | 依赖、配置等杂项 |

---

## 二、板块指南

### 1. 教程板块（核心板块）

**功能定位**：博客的核心内容资产。体系化技术教程按「分类 × 系列」两级组织，是社团对外知识输出的主阵地。目前有 Python（11 篇）、C++（12 篇）、Java（12 篇）三个完结系列。

**主要内容**：

- **分类（category）**：横向大方向，决定文章出现在哪个分类页。现有分类：`Python 教程`、`C++ 教程`、`Java 教程`、`网络安全`、`社团动态`、`技术分享`
- **系列（series）**：纵向课程，同系列文章自动聚合、按序号排序，读者可按课程顺序学习
- 每篇教程统一结构：本篇目标 → 分节讲解（含避坑提示）→ 小练习 → 小结 + 下篇预告

**更新方法**：在 `src/content/posts/` 新建 Markdown 文件（文件名与 slug 一致），frontmatter 模板：

```markdown
---
title: 系列名（N）：本篇主题
published: 2026-10-29
description: 一句话摘要（60字内，列表页展示）
tags: [技术名, 教程]
category: 技术分享            # 按上方分类表选
slug: web-tutorial-01         # 与文件名一致，英文短横线
series: "Web 开发教程"         # 同系列必须一字不差
seriesOrder: 1                # 系列内序号
---

正文内容，支持标准 Markdown……
```

也可以用脚手架：`pnpm new-post` 按提示生成模板。详细写作规范见 [docs/tutorial-rules.md](./docs/tutorial-rules.md)。

**注意事项**：

- **开新系列先报备**：系列规划（目标/篇目清单）先发社团群讨论，避免撞车
- **series 字符串严格一致**：一个标点不同就会分裂成两个系列
- **代码必须可运行**：发布前本地跑一遍所有示例，附预期输出
- **版权红线**：可参考任何资料的知识体系，但文字/示例/结构必须原创，禁止搬运菜鸟教程、CSDN 等站点内容
- **单篇 1500~3500 字**；图片放 `src/content/posts/images/` 文章同名目录，相对路径引用
- 涉及漏洞利用的内容必须限于合法靶场/授权测试场景，附免责说明

### 2. 动态板块（说说）

**功能定位**：轻量级内容出口——一段感想、一条通知、一个链接，比文章门槛低得多。适合日常冒泡、活动预告、快讯转发。展示在导航「社团 → 动态」，侧边栏也有最近动态组件。

**更新方法**：在 `src/content/dynamic/` 新建文件（建议 `日期-主题.md`）：

```markdown
---
title: 今晚直播分享会开始啦
published: 2026-10-29
description: 八点开始，链接在正文
tags:
  - 活动
mood: 🎤
---

今晚八点 B 站直播间，主题是 AI 工具实践，不见不散！
```

**注意事项**：频率自由、随手就发；但内部会议链接、成员私人信息等不公开内容禁止上站；`published` 写当天日期（决定排序）。

### 3. 成员板块（主页展示墙）

**功能定位**：社团成员的 GitHub 主页展示墙，每位成员一张卡片，点进去看个人名片和代表项目。入口：导航「社团 → 成员」。

**主要内容**：每张卡片 = `src/content/projects/` 下的一个 md 文件。封面用 GitHub 头像，详情页含成员名片（GitHub/身份/仓库数）、社团贡献、代表项目简介。**`order` 数值越大排越前（降序）**。

**更新方法（新成员加入）**：复制 `member-marktom.md` 为模板，修改四处：

1. `title`：成员名 / GitHub 昵称
2. `image`：`https://avatars.githubusercontent.com/u/<用户ID>?v=4&s=160`（160 是小尺寸参数）
3. `link` 里的 `value`：成员 GitHub 主页 URL
4. `order`：现有成员用 100、99、98… 递减，新成员排后面

正文按模板写名片、贡献、代表项目（简介可参考仓库描述扩写）。

**注意事项**：展示内容需本人同意（头像、主页、简介涉及个人信息）；项目简介保持客观；Fork 的项目标注"Fork 自 xxx"。

### 4. 相册板块

**功能定位**：社团活动照片墙，按相册分组、瀑布流展示。入口：导航「社团 → 相册」。当前为空，等待第一批活动照片。

**更新方法（添加一个相册）**：

1. 建目录 `public/gallery/activity-2026-10/`，放入照片（可放一张 `cover.jpg` 做封面）
2. 在 `src/config/galleryConfig.ts` 的 `albums` 数组加一项：

   ```ts
   {
       id: "activity-2026-10",           // 与目录名一致
       name: "十月分享会",
       description: "第一次线下技术沙龙",
       location: "信息楼 301",
       date: "2026-10-29",
       tags: ["活动", "分享会"],
   },
   ```

**注意事项**：含人物照片发布前征得当事人同意；单张压缩到 500KB 内、整相册别超 20MB；优先 webp 格式；内部活动可加 `password` 字段设密码。

### 5. 友链板块

**功能定位**：与其他博客/社团的互换链接，站点的社交名片。入口：导航「社交 → 友链」。

**更新方法**：在 `src/config/friendsConfig.ts` 加一项：

```ts
{
    title: "某某的博客",
    imgurl: "https://example.com/avatar.png",
    desc: "一句话介绍",
    siteurl: "https://example.com",
    tags: ["Blog"],
    weight: 7,        // 数字越大排越前
    enabled: true,
},
```

**注意事项**：加友链前先和对方站长打招呼，最好互换（我们的地址 `https://www.cyberpioneer.club`）；每学期检查一轮，清理打不开的链接。

### 6. 留言板

**功能定位**：访客留言交流区。当前未接评论系统，暂作为社团联系说明页。内容在 `src/content/spec/guestbook.md`，直接编辑正文即可（如更新群号、公开联系方式）。

**注意事项**：想开真评论需在 `src/config/commentConfig.ts` 配置第三方服务（Twikoo/Waline），动手前群里讨论选型；文案只放公开邮箱/群号。

### 7. 关于页（社团介绍）

**功能定位**：社团官方门面——新人了解社团的第一站。内容在 `src/content/spec/about.md`。

**注意事项**：重要变更才更新（定位调整、纳新季、联系方式变化）；新开教程系列后同步这里的"教程板块总览表"。

### 8. 公告（侧边栏）

**功能定位**：首页侧边栏置顶通知条，适合纳新、活动预告等**时效性强的全局通知**。

**更新方法**：编辑 `src/config/announcementConfig.ts` 的 `content` 与 `link`（可跳转到站内文章详情）。

**注意事项**：公告位只有一条，新公告覆盖旧内容；活动结束后关闭（清空内容），别让过期通知一直挂；全站生效，措辞正式一点。

### 9. 轮播壁纸（首页 banner）

**功能定位**：首页顶部氛围大图，桌面端与移动端分别配置，支持多张随机轮播。当前各有一张社团定制 AI 壁纸。

**更新方法**：新图放入 `src/assets/images/DesktopWallpaper/`（宽幅 16:9）或 `MobileWallpaper/`（竖幅 2:3），在 `src/config/backgroundWallpaper.ts` 对应数组**最前面**加一行路径。banner 文字（主标题/打字机副标题）在同文件 `homeText` 配置。

**注意事项**：尺寸匹配（桌面宽幅/移动竖幅，放错显示异常）；单张压缩到 300KB 内；banner 主标题是社团名称，别随意改；配图风格参照 [docs/image-prompts.md](./docs/image-prompts.md)。

### 10. 书签导航板块

**功能定位**：常用工具与资源站点导航集合页。入口：导航「社团 → 书签导航」。

**更新方法**：在 `src/config/booknavConfig.ts` 对应分组的 `items` 加一项（title/url/desc/icon/weight），或新增分组。

**注意事项**：只收优质常用站，宁缺毋滥；**iconify 图标名用连字符**（`material-symbols:xxx`），下划线会导致构建失败；链接失效及时移除。

### 11. 音乐播放器（当前关闭）

**功能定位**：站点背景音乐。当前未启用。想开的话在 `src/config/musicConfig.ts` 配置（mode 选 meting 歌单或本地 mp3），开启前群里商量曲目版权。

### 12. 站点全局配置速查

日常一般不动，但要知道在哪：

| 配置文件 | 管什么 | 动它的时机 |
| --- | --- | --- |
| `src/config/siteConfig.ts` | 站点标题/描述/关键词/导航开关 | 站点定位级变更（需全员讨论） |
| `src/config/navBarConfig.ts` | 导航菜单结构与名称 | 增删栏目时 |
| `src/config/profileConfig.ts` | 侧边栏头像/名称/签名/社交链接 | 换主页链接、换头像 |
| `src/config/sidebarConfig.ts` | 侧边栏组件开关与排序 | 调整侧边栏内容 |
| `src/config/backgroundWallpaper.ts` | 壁纸与 banner 文字 | 见板块 9 |
| `src/config/musicConfig.ts` | 背景音乐（当前关闭） | 想开音乐时 |
| `src/config/analyticsConfig.ts` | 访问统计 | 想看流量数据时 |
| `src/config/commentConfig.ts` | 评论系统（未启用） | 开评论前群内讨论 |

> 改任何 `src/config/` 下的文件后，本地跑一次 `pnpm build` 确认没改坏再 push——配置语法错误会导致自动构建失败，线上停留旧版本。

---

## 三、站点架构速览

| 项目 | 说明 |
| --- | --- |
| 框架 | Astro v7（纯静态生成） |
| 主题 | [Firefly](https://github.com/CuteLeaf/Firefly)（MIT 协议，基于 Fuwari） |
| 站点配置 | `src/config/siteConfig.ts`（标题/描述/导航/页面开关） |
| 文章目录 | `src/content/posts/` |
| 成员展示 | `src/content/projects/` |
| 动态（说说） | `src/content/dynamic/` |
| 字体 | 本地 woff2（`src/assets/fonts/`），不依赖外部 CDN |
| 托管 | GitHub 仓库 + Cloudflare Pages 自动构建，绑定自定义域名提供 HTTPS |
| 构建环境 | Node 22 + pnpm，构建命令 `pnpm build`，产物目录 `dist` |

---

## 四、常见问题与维护节奏

### Q1：push 之后线上没更新？

- 检查 GitHub 仓库最新 commit 是否包含你的改动
- 到 Cloudflare Dashboard → Workers & Pages → 项目 → Deployments 看构建状态（需管理员权限）
- 构建失败最常见原因：frontmatter 语法错误、配置文件 TypeScript 语法错误、iconify 图标名用了下划线

### Q2：文章里的图片放哪？

`src/content/posts/images/` 下建与文章同名目录，正文相对路径引用 `./images/xxx.png`，构建时自动压缩优化。

### Q3：想下线一篇文章？

删除文件，或给 frontmatter 加 `draft: true`（转草稿）。

### Q4：内容红线（必读）

1. **服务器运维信息不上站**：IP、账号、内部路径不写入仓库与文章
2. **安全类内容限合法场景**：漏洞利用教程必须限于靶场/授权测试，附免责说明
3. **个人隐私需授权**：照片、主页、真实姓名上站前征得本人同意
4. **版权**：文字原创，图片自备（AI 生成或授权素材），不搬运第三方站点内容

### 日常维护节奏建议

| 频率 | 事项 |
| --- | --- |
| 随时 | 动态、文章更新 |
| 每月 | 检查友链有效性、公告是否过期 |
| 每学期 | 关于页信息核对、教程总览表更新、成员墙信息核对 |

---

## 五、许可

- 站点主题 Firefly 遵循 [MIT License](./LICENSE)
- 文章内容版权归原作者所有，转载请联系社团

*本手册随站点演进持续更新，发现描述与实际不符，直接修改本文件并 push。*
