# Cyber先锋社 · AI 图像生成提示词手册

为社团博客各图片位置设计的统一风格提示词集。所有提示词遵循同一视觉体系，可保证全站配图风格一致，直接复制到任意 AI 图像生成工具（即梦、Midjourney、DALL·E、Stable Diffusion 等）使用。

> 生成后图片放置路径与主题引用方式见每节末尾的「接入方式」。

---

## 🎨 全站统一视觉规范

为了让不同位置、不同工具生成的图片风格统一，所有提示词共享以下基调：

| 要素 | 规范 |
| --- | --- |
| **主题色** | 青绿色系（#10B981 附近，可带少量蓝紫渐变点缀） |
| **风格基调** | 现代简约 + 科技感；扁平插画或轻写实数字艺术，避免照片级写实 |
| **画面语言** | 网络安全元素：盾牌、锁、电路纹理、二进制流、终端窗口、网络拓扑 |
| **通用后缀** | 所有提示词末尾追加：`clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark` |

---

## 1️⃣ 首页轮播封面图（桌面壁纸）

**建议尺寸**：2416×1376（16:9），最小不低于 1920×1080
**适用场景**：首页 banner 轮播背景，文字叠加在图上，需留出中央视觉呼吸空间

### 提示词 A：数字护盾（主推）

```text
A glowing digital shield emblem floating at the center-right of a wide panoramic scene, surrounded by flowing streams of binary code and circuit lines, deep navy-to-teal gradient background, soft light rays emanating from behind the shield, large empty dark space on the left third for text overlay, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark --ar 16:9
```

### 提示词 B：网络都市

```text
A futuristic city skyline made of glowing circuit boards and network nodes, data streams flowing between buildings like light trails, night scene with teal and emerald neon glow, silhouette of a shield constellation in the sky, wide 16:9 panoramic composition with darker bottom half for text readability, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark --ar 16:9
```

### 提示词 C：赛博钥匙

```text
An ornate glowing key transforming into data particles as it unlocks a holographic padlock, centered composition with particle trails spreading horizontally, deep blue-green gradient background with subtle hexagonal grid pattern, balanced negative space above and below the subject, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark --ar 16:9
```

**接入方式**：放入 `src/assets/images/DesktopWallpaper/`，使用自定义命名（如 `club-banner-01.avif`），在 `src/config/backgroundWallpaper.ts` 的 `desktop` 数组中引用。

---

## 2️⃣ 移动端轮播封面图

**建议尺寸**：1404×2052（2:3 竖版）
**适用场景**：手机访问时的 banner 背景，主体应居中偏上

### 提示词 A：悬浮盾徽（主推）

```text
A luminous geometric shield emblem hovering above a pedestal of stacked translucent digital layers, vertical composition with the shield in the upper-center area, binary code rain fading downward into darkness, deep teal gradient background, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark --ar 2:3
```

### 提示词 B：上升数据流

```text
A vertical stream of glowing data particles rising from the bottom like a digital aurora, forming the silhouette of a key at the top, night sky background with faint circuit constellation patterns, teal and emerald glow dominating the frame, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background suitable for white text overlay, high detail, no text, no watermark --ar 2:3
```

**接入方式**：放入 `src/assets/images/MobileWallpaper/`，在 `backgroundWallpaper.ts` 的 `mobile` 数组中引用。

---

## 3️⃣ 文章头图 / 封面图

**建议尺寸**：1600×900（16:9）
**适用场景**：文章列表卡片封面与文章详情页顶部头图；frontmatter 的 `image` 字段引用

### 提示词 A：主题式终端（技术分享类文章，主推）

```text
A sleek holographic terminal window floating in dark space, displaying abstract glowing code lines and a padlock icon, keyboard keys dissolving into light particles below, teal screen glow reflecting on a dark desk surface, wide 16:9 composition with the terminal slightly off-center, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 16:9
```

### 提示词 B：解谜之门（CTF 竞赛类文章）

```text
A mysterious glowing door covered with digital runes and binary symbols, a small figure holding a light key walking toward it, dramatic teal spotlight from the door gap, dark cyber atmosphere with floating holograms, wide cinematic 16:9 composition, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 16:9
```

### 提示词 C：防御矩阵（安全防护类文章）

```text
An abstract fortress made of layered translucent hexagonal barriers, incoming red attack arrows dissolving at the shield boundary, calm teal core glowing at the center, isometric perspective, wide 16:9 composition, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 16:9
```

**接入方式**：文章封面放 `src/content/posts/images/`，文章 frontmatter 写 `image: ./images/cover.png`；不指定时可在 frontmatter 写 `image: "api"` 使用随机图。

---

## 4️⃣ 内容卡片封面图（项目展示 / 相册 / 动态）

**建议尺寸**：1200×675（16:9）或 1080×1080（1:1，网格布局）
**适用场景**：项目展示卡片、相册缩略图、动态配图

### 提示词 A：工具矩阵（项目展示，主推）

```text
A collection of floating holographic tool icons (magnifier, wrench, terminal, gear) arranged in a neat grid around a central glowing core, each tool connected by thin light lines, dark tech background, square 1:1 composition with balanced spacing, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 1:1
```

### 提示词 B：活动剪影（社团活动类）

```text
Silhouettes of a group of young people gathered around glowing holographic screens in a dark room, one person pointing at a floating shield hologram, collaborative hacking-learning atmosphere, teal light illuminating the scene from the screens, 16:9 composition with subjects in the lower two-thirds, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 16:9
```

### 提示词 C：奖杯时刻（赛事战报类）

```text
A glowing digital trophy on a pedestal made of stacked code blocks, confetti made of binary digits falling around it, subtle CTF flag icon floating beside the trophy, dark background with spotlight effect, 16:9 composition with the trophy slightly right of center, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 16:9
```

**接入方式**：项目封面在 `src/content/projects/` 对应 md 的 frontmatter `image` 字段引用；动态配图随动态文件存放。

---

## 5️⃣ 侧边栏 / 页脚装饰图

**建议尺寸**：800×400（2:1 横条）
**适用场景**：侧边栏公告配图、打赏页装饰、留言板头图等窄横幅位置

### 提示词 A：电路地平线（主推）

```text
A minimal landscape where the horizon is formed by a glowing circuit board trace, tiny padlock and shield icons as stars in the dark sky above, calm and quiet atmosphere, ultra-wide 2:1 banner composition with most space being atmospheric gradient, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 2:1
```

### 提示词 B：像素流光

```text
A smooth horizontal stream of glowing pixels flowing like a river through darkness, small islands of floating icons (key, lock, bug, flag) along the banks, gentle motion blur, ultra-wide 2:1 banner composition, clean composition, modern flat tech illustration, teal and emerald color palette with subtle blue-purple accents, dark background, high detail, no text, no watermark --ar 2:1
```

**接入方式**：放 `src/assets/images/` 或 `public/assets/images/`，在对应配置（如公告组件）中引用路径。

---

## 🛠️ 使用建议

1. **批量生成时锁定种子**：同一组图尽量用相同 seed / 风格参考图，风格更统一
2. **中英文皆可**：以上为英文提示词（通用性最好），中文工具可直接翻译使用，关键是保留「风格后缀」不删
3. **格式处理**：生成后转 WebP/AVIF 可显著减小体积（主题构建时对 `src/` 下的图自动优化）
4. **占位方案**：临时缺图时，文章 frontmatter 写 `image: "api"` 走随机图
5. **署名规范**：AI 生成图建议在图片说明或文末标注「封面由 AI 生成」
