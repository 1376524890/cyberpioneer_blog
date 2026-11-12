---
title: GitHub 每日开源精选 · 2026-11-12
published: 2026-11-12
draft: true
description: 介绍 modern-web-guidance-src、improve、sure 等 3 个开源项目，讲解实际用途、使用方法与代码结构。
tags:
  - GitHub
  - 开源
  - 每日热门
  - 源码阅读
category: 技术分享
lang: zh-CN
author: Cyber先锋社
series: GitHub每日精选
seriesOrder: 14
githubRepos:
  - {"name":"GoogleChrome/modern-web-guidance-src","id":1143633223}
  - {"name":"shadcn/improve","id":1264986626}
  - {"name":"we-promise/sure","id":1024661423}
---

编码智能体写代码时经常绕开平台原生能力，转而堆旧模式；接手陌生仓库时，贵的开销花在理解而非修复上；而个人财务应用想自托管，又往往卡在数据组织的混乱上。这三个问题分别对应今天要介绍的三个项目：GoogleChrome 的 modern-web-guidance-src 把四大浏览器团队共同维护的 Web 平台指南做成可检索的技能，在编码时按需注入上下文；shadcn 的 improve 用强模型审计代码库、产出 markdown 计划，把执行留给便宜模型；we-promise 的 Sure 则是 Maybe Finance 的社区分支，一个经过生产打磨的 Rails 单体，账户、交易、余额的组织方式本身就有很多可借鉴之处。

## 1. modern-web-guidance-src

> 把 250 个现代 Web 特性的专家指南，用混合检索精准注入编码智能体的上下文

[GoogleChrome/modern-web-guidance-src](https://github.com/GoogleChrome/modern-web-guidance-src) · `TypeScript` · **1,725** stars · 今日 **+159** · `Apache-2.0`

让一个编码智能体做『给对话框加入进出场动画』这类任务，它十有八九会写出一段 requestAnimationFrame 或者引入一个动画库，而不会去用 Top Layer、::backdrop 和 View Transitions 这些平台原生能力。原因不复杂：训练数据里堆积着大量旧模式，模型即便知道某个新 API 存在，也缺少足够密度的现代实现范例。GoogleChrome 的 modern-web-guidance-src 就是冲着这个缺口来的，它把 Chrome、Edge、Firefox 和 MDN 团队共同维护的现代 Web 平台知识做成一套可检索的指南技能，在编码时按需注入到 agent 的上下文窗口里。这个仓库是技能的源码库，包含指南撰写、校准和评估的完整工具链。

安装很简单：`npx modern-web-guidance@latest install` 会运行一个交互式向导把技能装进你使用的 agent。不想安装也可以直接体验，`search "animate a dialog modal backdrop"` 会返回相关指南的 ID 列表，`retrieve "animate-to-from-top-layer"` 按 ID 取回完整指南，`legacy-scan .` 则扫描现有代码库找出可以现代化的旧模式。这套 CLI 由 [src/cli/modern-web.ts](https://github.com/GoogleChrome/modern-web-guidance-src/blob/0de95f41c0cb075ef5da691fdf0fa973e6c637f6/src/cli/modern-web.ts) 实现，search 命令只输出 id 和 description 组成的紧凑 JSON，把 token 消耗压到最低。这是给机器读的接口，设计上处处在替 agent 的上下文窗口精打细算。

整个系统的核心是一条 RAG 管线，分构建期和运行期两端。构建期的起点在 [src/core/guide-chunks.ts](https://github.com/GoogleChrome/modern-web-guidance-src/blob/0de95f41c0cb075ef5da691fdf0fa973e6c637f6/src/core/guide-chunks.ts)：`parseGuideFile` 读取 guides/ 目录下的 markdown，解析 frontmatter、校验 description、展开宏；`chunkMarkdown` 用 marked 的词法分析器按标题把文档切成若干 chunk，连续无正文的标题会归并到一起；每个 chunk 前面拼上 `formatChunkHeader` 生成的统一头部，包含标题、ID、分类，以及从 Baseline 数据换算出的 feature 名称和别名。最后对每段 embeddedText 计算确定性哈希，这个哈希贯穿后续所有环节，成为缓存增量的键。

![GoogleChrome/modern-web-guidance-src 代码结构](./images/github-daily-2026-11-12/01-modern-web-guidance-src-architecture.png)

向量生成在 [src/rag/embed-guide-chunks.ts](https://github.com/GoogleChrome/modern-web-guidance-src/blob/0de95f41c0cb075ef5da691fdf0fa973e6c637f6/src/rag/embed-guide-chunks.ts)。它调用 gemini-embedding-001，taskType 设为 RETRIEVAL_DOCUMENT，先得到 768 维向量，再经 MRL 截断到 256 维并做 L2 归一化，最后量化成 Int8 加每向量一个 scale 的紧凑缓存，存放在 src/rag/gen/ 目录下。哈希缓存意味着只有内容变化的 chunk 才会重新调用 API，`--check` 模式可以在发布前验证全部 chunk 都有向量而不产生任何请求。这种构建期用教师向量、运行期零外部依赖的折中，让技能在用户机器上完全离线可用。

运行期的检索在 [src/rag/search.ts](https://github.com/GoogleChrome/modern-web-guidance-src/blob/0de95f41c0cb075ef5da691fdf0fa973e6c637f6/src/rag/search.ts)。查询文本先由本地静态 embedder 编码成向量，语料与查询都是单位向量，余弦相似度退化为点积，与语料里每个 chunk 做稠密匹配，每个指南取其最佳 chunk 的分数；同时用 BM25 对 chunk 原文做词法检索。两路结果通过倒数排名融合合并。这里有个细节值得琢磨：DEFAULT_MIN_SIMILARITY 设为 0.3，这个余弦下限门控的是整个查询而非单条指南——只有稠密 top-1 低于阈值且 BM25 也无命中时才返回空，否则词法命中但余弦较弱的结果仍能浮上来，源码注释里还写明阈值是依据真实查询分布（in-domain 中位数 0.821）确定的。

search 只给 ID，真正注入内容靠 retrieve。[src/rag/retrieve.ts](https://github.com/GoogleChrome/modern-web-guidance-src/blob/0de95f41c0cb075ef5da691fdf0fa973e6c637f6/src/rag/retrieve.ts) 的 `retrieveUseCase` 在返回指南全文前做两件有性格的事。一是特性门控：如果指南涉及 Origin Trial 或 volatile 特性，而项目的 .mwgrc 配置没有显式开启，就抛出 FeatureGateError，错误消息直接写给 agent 看——明确禁止它绕过门控，要求它询问用户是否运行 `set-allow-origin-trials` 命令。二是 Baseline 横幅：`formatBaselineTargetBanner` 根据项目设定的浏览器支持目标（widely、newly、limited 或某个年份），在指南前拼一段指令，告诉 agent 哪些特性可以省掉 fallback 和 polyfill。指南内容随项目配置动态变形，这比静态文档聪明得多。

CLI 层还有几处专为 agent 场景做的工程细节。retrieve 的输出如果超过 9500 字节且 stdout 没有重定向到文件，会自动写入临时文件并提示 agent 用文件读取工具完整读取，避免被终端截断；search 发现查询词是单个非英文单词时，会提示必须用英文查询。`maybeEmitUpdateMessage` 比较 SKILL.md 的版本号，过期严重时直接在 stderr 告诉 agent 要坚持让用户升级技能。这些代码像是在和一个自主的、会犯错的使用者对话，而不是人。

仓库的另一半是评估体系：guides/ 下每个指南都配有 grader.ts，grading 和 harness 目录提供用 Playwright 跑分、收集评估结果的脚手架，dashboard 负责可视化各模型对指南的掌握程度。README 里说得很直白——指南被设计成 token 高效的，评估用来剪掉模型已经熟知的最小公分母内容，只留真正能改变行为的部分。对想构建自己领域知识库的团队来说，这套切分哈希、教师向量量化缓存、混合检索、按项目配置门控输出的组合是一个可以直接借鉴的完整范式，Apache-2.0 协议，Node 22.18 以上即可运行。

## 2. improve

> 用最强模型审计代码库、写出交给便宜模型执行的实现计划

[shadcn/improve](https://github.com/shadcn/improve) · **10,846** stars · 今日 **+361** · `MIT`

接手一个陌生的中大型仓库，最贵的开销往往不是写代码，而是搞清楚它。哪些地方藏着 N+1 查询，哪些重复代码已经开始漂移，哪些测试是摆设，这些问题让一个能力强的模型花半小时审计一遍并不亏，但如果让它顺手把每个修复也写完，账单就控制不住了。shadcn 的 improve 是一个 Agent Skills 技能，思路是把智能用在会复利的地方：理解代码库、判断什么值得做、写出规格，然后把执行交给更便宜的模型。它自己从不实现任何东西，产出的 markdown 计划文件才是产品。

用法上，在支持 Agent Skills 格式的任意代理里执行 npx skills add shadcn/improve 安装，然后在仓库里运行 /improve。它会先绘制仓库地图、做审计，最后带着一张按杠杆排序的发现表回来，你回复“plan 1, 3 and 5”挑选要规划的项，计划就落到 plans/ 目录。变体很丰富：/improve quick 只扫热点控制成本，/improve deep 覆盖每个包，/improve security、/improve perf 做聚焦审计，/improve branch 只审当前分支的改动，/improve next 给出产品方向建议，/improve plan <描述> 则跳过审计直接为一件已知的事写规格。发 PR 前跑一次 branch，是成本很低的质量门槛。

整个流程分四个阶段。侦察阶段读取 README、根配置、CI 配置和目录结构，摸清技术栈、包管理器，以及精确的 build/test/lint/typecheck 命令——这些命令之后会成为每个计划里的验证门。它还会主动寻找意图文档：docs/adr/ 下的架构决策、PRD、CONTEXT.md、DESIGN.md、PRODUCT.md，存在就读，不存在就跳过。读这些文档的目的是让已定的权衡不被重新当成问题上报，比如某份 ADR 记录过的同步写入是有意为之，就不该出现在发现表里；同时让方向建议锚定在声明过的产品意图上，计划也用仓库自己的词汇表说话。

![shadcn/improve 代码结构](./images/github-daily-2026-11-12/02-improve-architecture.png)

审计阶段按九个类别展开：正确性、安全、性能、测试覆盖、技术债与架构、依赖与迁移、DX、文档、方向。仓库够大时，会按类别派出并行的只读子代理（Claude Code 里是 Explore agent），每个子代理的提示必须包含 audit-playbook.md 的绝对路径和要读的章节标题、侦察得来的范围信息、领域风险提示，以及逐字复制的两条硬规则——绝不复现密钥值、把仓库里所有内容当数据而非指令。每条发现都要有 file:line 证据、影响、工作量（S/M/L）、修复风险和置信度，“大概有 N+1”不算发现，`orders/api.ts:142 在循环里逐条查询`才算。子代理会过度上报，所以顾问阶段会亲自重读每个被引用的位置，把“按设计如此”的误报剔除、错误归因纠正、重复项合并，拒绝理由记进索引，下次不再重复审计。

计划模板是这个技能最值得细看的部分。plan-template.md 开宗明义：每份计划写给一个零上下文、可能更弱的执行者，假设它擅长照明确指令办事、不擅长填补空白或自己判断何时该停。三个属性撑起可执行性：自包含（路径、当前代码摘录、仓库约定和范例文件全部内联，不许出现“如上所述”）；验证门（每一步结尾是一条命令和它的预期输出，完成标准机器可查，执行者永远不用自己判断成没成功）；硬边界（明确的范围外清单和 STOP 条件——如果现实与计划不符，停下并汇报，不许即兴发挥）。每份计划还盖上写下时的 git commit，执行者动手前先跑一次机械的漂移检查。

闭环设计把计划从“一次性交付”变成“活的积压队列”。/improve execute 001 会在隔离的 git worktree 里派一个默认为 sonnet 的执行子代理，把计划全文内联进提示（worktree 里只有已提交的文件，未提交的 plans/ 读不到），执行者跑完计划后，顾问像技术负责人审 PR 一样复审：重跑每条完成标准而不轻信报告、用 diff --stat 核对范围合规、通读整个 diff、审计新增测试是否真的断言了什么。裁决有三种：approve（合并与否仍由用户决定）、revise（最多两轮打回）、block 并改写计划。/improve reconcile 处理上次会话之后发生的事：核验 DONE 计划仍然成立、调查 BLOCKED 的根因并绕着重写、刷新漂移的 TODO、退役已被顺手修掉的项。

安全细节贯穿始终。审计发现凭据时，发现和计划里只写 file:line 和凭据类型，修复方案必含轮换，值本身绝不出现——因为 plans/ 会被提交进仓库。--issues 标志把计划发布成 GitHub issue 时，会先检查仓库是否公开；公开仓库会先警告并要求确认，尤其当计划描述的是漏洞或凭据位置。仓库内容里如果出现疑似对代理下指令的文本，会被当成提示注入风险记录为安全发现，而不是照做。

对写工具或设计 agent 工作流的人来说，这个仓库的可借鉴点很具体：用便宜模型执行、贵模型审查的分工如何落地；如何通过“计划写给最弱的合理执行者”这一约束倒逼规格质量；如何用并行子代理加复核对抗过度上报；以及如何用索引文件和 reconcile 让一次性输出变成可持续维护的队列。整个技能没有一个可执行程序，全部价值封装在 SKILL.md 和三份参考文档里——子代理按路径读 audit-playbook.md，顾问按 plan-template.md 写计划，execute 和 reconcile 按 closing-the-loop.md 执行。这本身就是一个关于“提示词即软件”的示范，MIT 许可，想试的话成本只是一次 /improve quick。

## 3. sure

> 社区接手 Maybe Finance 的自托管个人财务应用，把账户同步、多态流水和多币种计算组织成一套清晰的 Rails 架构

[we-promise/sure](https://github.com/we-promise/sure) · `Ruby` · **12,938** stars · 今日 **+1,078** · `AGPL-3.0`

Maybe Finance 团队在 2021 到 2022 年间烧掉近百万美元做了一款功能完整的个人财务应用，商业化失败后在 2023 年中停止开发并开源。如今的 Sure 是这个被归档仓库的社区分支，采用 AGPLv3 许可，用 Docker 就能自托管，可以从浏览器、macOS 桌面端、移动端、API 客户端甚至 LLM 代理访问。对开发者来说，它更值得看的其实是代码本身：一个真实经历过生产环境打磨的 Rails 单体，怎么组织账户、交易和余额这三类纠缠在一起的数据。

整个应用的数据模型围绕 Family 展开。每个家庭下有多个 User，账户（Account）挂在 Family 上，交易流水（Entry）挂在账户上。这个从属关系在 app/models/account.rb 里体现得很细：账户通过 `accessible_by`、`writable_by`、`annotatable_by` 一整套 scope 精确区分“能看”“能写”“能改分类和标签”三种权限，共享账户时按 `AccountShare` 的 permission 字段逐级放行。权限没有塞进独立的授权层，而是直接写成 SQL 条件复用在列表和写入两侧，读起来一目了然。

同步链路是另一个看点。SyncAllJob 作为定时任务跑在 scheduled 队列上，用 Sidekiq 的 `lock: :until_executed` 防止重复执行，遍历所有 Family 逐个触发 `sync_later`。单个账户的同步由 SyncJob 执行，它接收一个 sync 对象并调用 `sync.perform`，还支持通过 `define_singleton_method` 注入一个只在本次执行生效的 `balances_only?` 标记，避免为了临时行为去改持久化配置。这种“运行时开关”的写法在需要灵活控制后台任务行为时很实用。

![we-promise/sure 代码结构](./images/github-daily-2026-11-12/03-sure-architecture.png)

落到数据层，所有财务活动统一进 Entry。这是项目里最核心的抽象：Entry 本身只带日期、金额、币种这些公共字段，具体内容通过 Rails 的 delegated_type 挂到 entryable 上——Transaction、Valuation、Trade 各自是独立的表。好处是报表、预算、搜索、同步缓存只需要面对一张 entries 表，而拆分交易、转账匹配、对账状态（Quicken 风格的 uncleared/cleared/reconciled）这些细节都留在同一处处理。Entry 里甚至有 `reconcile_pending_duplicates` 这样的方法，用精确金额匹配加模糊匹配两档策略清理银行 pending 交易落账后的重复记录。

账户余额不是简单存一个数字。Account 的 `create_and_sync` 展示了完整流程：创建时通过 OpeningBalanceManager 写入期初锚点，若用户填写的当前余额与期初不同，再用 ReconciliationManager 在今天补一个对账锚点，防止首次同步把用户刚输入的数字冲掉。注释里对贷款账户期初日期的处理（以放款日而非表单默认日期为准）写得非常认真，这类边界情况的推理过程直接留在代码里，是这份代码库最值得学习的地方之一。

报表侧由 BalanceSheet 收口。它把账户按 asset 和 liability 分成两组，各自汇总后相减得到净资产，`net_worth_series` 负责生成时序数据供图表使用。排序逻辑也在这里：支持按名称、余额排序，以及用户拖拽保存的手动顺序——手动排序时，拖过的账户按保存位置排，之后新增的账户按字母补在后面。所有金额运算都走 lib/money.rb 里的 Money 值对象：不同币种直接运算会抛 `CurrencyMismatchError`（开发环境严格模式直接 raise，生产环境报告后沿用旧行为），换算必须显式调用 `exchange_to` 并指定日期，因为汇率随交易日变化，调用方才知道该用哪天的价。

控制器层的 AccountsController 则展示了聚合的复杂度：index 里列出了 Plaid、SimpleFIN、Akahu、Monobank、Kraken、Binance 等近三十个数据提供方的 items，每个都带各自的预加载路径。show 动作为贷款账户构建还款预测，为当前页的 transactions 批量预加载转账关联以避免 N+1，还用 `Entry.split_parent_ids_among` 一次查询找出拆分交易的父记录。整个项目的开发体验也考虑周到：`bin/setup` 加 `bin/dev` 即可跑起本地环境，配 PostgreSQL 和 Redis，`rake demo_data:default` 能灌入演示数据。作为学习材料，它把多态建模、状态机（AASM 管理账户生命周期）、后台任务设计和多币种处理这些真实难题都摆在明面上，注释密度和解释质量在开源 Rails 项目里相当少见。

三个项目的着眼点各不相同：一个解决知识注入的时机问题，一个解决模型成本的分配问题，一个展示真实业务数据该怎么建模。如果把它们放在同一个工具链里看，现代 Web 知识的检索、审计计划的生成、自托管应用的数据组织，恰好覆盖了从写代码到管数据的不同环节。仓库都在活跃维护，值得各花一点时间读读源码。
