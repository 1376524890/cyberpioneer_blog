---
title: "2026年10月值得留意的五个开源项目：记忆、代理与排盘"
published: 2026-10-30
draft: true
description: 代理写代码越来越顺手，麻烦却转移到会话之外：关掉终端，上下文就断了；让模型做设计，它交出的界面像同一个模板刻出来的；想让 agent 去外部系统里办事，又不敢把浏览器和文件权限直接交出去。这一期挑的五个项目，分别在这些缝隙里做文章——有的把
tags:
  - GitHub
  - 开源
  - 每日热门
  - 源码阅读
category: 技术分享
lang: zh-CN
author: Cyber先锋社
---

代理写代码越来越顺手，麻烦却转移到会话之外：关掉终端，上下文就断了；让模型做设计，它交出的界面像同一个模板刻出来的；想让 agent 去外部系统里办事，又不敢把浏览器和文件权限直接交出去。这一期挑的五个项目，分别在这些缝隙里做文章——有的把会话压成可检索的记忆，有的给每个 bot 分一台独立虚拟机，有的用确定性规则挡住“AI 味”界面，有的把计算机操作放进审批网关，还有一个把紫微斗数的排盘算法完整开源。它们解决的问题不同，共同点是都把“模型之外的那层工程”摆到了台面上。

## 1. claude-mem：把每次会话的工具调用压缩成可检索记忆，下次开工自动注入上下文

[thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) · TypeScript · ★ 105,580 · 今日 +1,145 · Apache-2.0

你在 Claude Code 里调试一个跨多个文件的 bug，关掉终端去吃饭，回来重新打开会话，模型已经忘了刚才定位到哪个函数、试过哪些方案。claude-mem 想解决的就是这种断裂：它挂在会话的生命周期上，把工具调用、决策、bugfix 等观察记录下来，压缩成结构化记忆，下一次会话开始时再把相关片段注入回上下文。安装入口很直接，`npx claude-mem install` 会配置好插件和 hook，并启动一个本地 worker 服务。

这套东西的核心是一个常驻的 worker。hook 在会话事件发生时把原始数据发给 worker，worker 负责落库、调用 LLM 做压缩摘要、生成向量索引，再通过 HTTP 接口把上下文提供给宿主。`src/integrations/harness-worker.ts` 里的 `createHarnessWorkerClient` 展示了这种协作方式：先请求 `/api/health`，只有连接被拒绝时才尝试拉起 worker，HTTP 层面的错误则直接抛出。这个区分很实用，避免把“服务在跑但返回 500”误判成“服务没启动”而重复拉起进程。

记忆的写入和读取是两条路径。写入侧由 hook 触发，把一次会话中的工具调用、文件读写、错误修复整理成 observation；读取侧则是一个 MCP 工具集，模型可以主动搜索历史记忆。`src/servers/corpus-worker-stream.ts` 处理的是长任务场景：构建或查询语料时，MCP 侧向 worker 发 SSE 请求，用 30 秒无 ping 判定 worker 失联，同时设 15 分钟绝对上限。它兼容旧版 worker 返回单次 JSON 的情况，通过 `content-type` 判断走哪条分支。

![thedotmack/claude-mem 代码结构](./images/github-daily-2026-10-30/01-claude-mem-architecture.png)

多宿主适配是项目里花力气较多的部分。OpenClaw 的插件入口 `openclaw/src/index.ts` 没有依赖 Claude Code 的 hook 体系，而是注册 `before_prompt_build`、`after_tool_call`、`session_start` 等事件回调，在提示构建前把记忆拼进 `prependContext`。同一个文件里还定义了 SSE 观察流和消息渠道推送，说明它把“记忆采集”和“记忆消费”拆成了可独立接入的两层，宿主只要能提供事件和消息通道，就能接上。

安装器本身也承担了运行时选择。`src/npx-cli/index.ts` 把 `install`、`repair`、`prune`、`update` 以及 worker 的启停都收在一个 CLI 里，`--provider` 可以选 claude、codex、gemini、openrouter 或 host。host 模式对应本地已有的 OpenAI 兼容观察器，`src/npx-cli/cmem-memory-credentials.ts` 里的 `probeHostObserverPort` 会探测 `/v1/models` 和 `/v1/chat/completions`，把端口状态分成 observer、occupied、free 三种，避免把别的服务误认成观察器。

值得借鉴的是它对“记忆”这件事的工程化处理。观察数据带类型（decision、bugfix、security_alert 等），有标题、事实、概念、读写文件列表，还有项目归属和会话编号。这些字段让后续检索不必只靠全文匹配，也给压缩摘要提供了稳定的输入结构。worker 把 LLM 调用、向量索引和 SQLite 存储放在同一个进程边界内，hook 侧只做轻量转发，减少了会话结束时的阻塞感。

另一处设计是凭据与配置的优先级。`resolveCmemMemoryCredentials` 按“本次投递、暂存、已配置”的顺序解析 cmem 网关密钥，并区分 `clearFallback` 是否应该清除降级标记。重跑安装不会被当成密钥恢复可用的证据，这种保守处理在多环境切换时能减少误判。配置读取也兼顾了 `settings.json` 的嵌套 `env` 和顶层两种形态，环境变量始终优先。

从代码组织看，claude-mem 把入口、worker 服务和宿主适配分得比较清楚：CLI 负责安装与运维，worker 负责采集、压缩和检索，各宿主插件只做事件转发和上下文注入。对想给自己的 agent 加持久记忆的开发者，这套分层比单个大而全的模块更容易替换其中一环，比如把 LLM 压缩换成别的模型，或者把存储从本地 SQLite 换到远端服务。

## 2. OpenMausBot：把 Claude、Codex 这类本地 agent 装进聊天应用，每个 bot 都有自己的虚拟机

[milind-soni/OpenMausBot](https://github.com/milind-soni/OpenMausBot) · TypeScript · ★ 8,111 · 今日 +899 · Apache-2.0

打开 OpenMausBot，侧边栏里每一行都是一个真实的 agent 进程，而不是一个套了壳的聊天接口。你可以像对待联系人一样给某个 bot 起名字、挑模型、配性格，然后发消息让它干活。它在本地跑 Claude 或 Codex CLI，用你机器上已有的登录和订阅，不需要再注册新账号，也没有中间代理转发你的对话。桌面端由 Electron 打包，macOS、Windows、Ubuntu 都有安装包，数据落在 `~/.openmausbot` 目录里。

真正让这些 bot 有“手”的，是它们各自可以挂载一台计算机。项目提供三种形态：云端 Linux 桌面、隔离的本地虚拟机，以及在明确授权后接管你自己的电脑。macOS 和 Ubuntu Xorg 下可以开启宿主机控制，Ubuntu Wayland 的支持因为输入注入问题暂时关闭。此外通过 Composio 接入 500 多个应用，bot 可以替你操作日历、邮件这类外部服务。这条链路的关键在于隔离边界：bot 拿到的是一个受限的执行环境，而不是你的整个用户会话。

服务端入口在 `server/cli.ts`，一个 `openmausbot` 命令就能把 harness 起在 `127.0.0.1` 上，默认端口 8799。子命令覆盖了 setup、serve、pair、sessions、status 等场景，`serve` 还支持 `--tailscale`、`--tunnel`、`--domain` 三种对外暴露方式，分别对应 Tailscale 内网、Cloudflare 隧道和自带 Caddy 的域名 HTTPS。参数解析和命令分发写在一起，`parseArgs` 把命令行和环境变量（如 `OMB_PORT`、`OMB_DATA_DIR`）合并成一份 `CliOptions`，后续逻辑只认这个结构，命令行细节不会渗进核心模块。

![milind-soni/OpenMausBot 代码结构](./images/github-daily-2026-10-30/02-openmausbot-architecture.png)

前端入口 `src/main.tsx` 做的事比一般 React 应用多。它在首屏渲染前先落定主题、字体、聊天宽度这些偏好，然后根据 `location.pathname` 决定挂哪个根组件：`/home` 是主屏，`/rail` 是 Electron 的侧边栏窗口（背景设为透明），`/pair` 是配对页，`/desktop-viewer` 是远程桌面视图。会话状态由一个 `readSessionState()` 统一裁决，未认证、loopback 但信任级别为 service、正常登录各有分支。这种把路由判断前置到挂载之前的写法，避免了先渲染主界面再跳登录页的闪烁。

bot 之间要协作，就需要一套受控的工具调用。`server/agent-tool-policy.ts` 里维护了一份只读工具白名单，`list_bots`、`list_threads`、`session_search`、`skills_list` 等十二个名字被显式列出，只有它们会拿到 `readOnlyHint: true` 这组注解。`isReadOnlyAgentTool` 只做精确匹配，不认前缀、不认大小写、也不认第三方 MCP 自己声明的注解。配套测试里专门列了一串反例：`mcp__agents__list_bots`、`agents.list_bots`、`LIST_BOTS` 全部判为不可读。名字相近就放行，是这类权限系统最常见的漏洞来源。

当 bot 需要跑在一台远程机器上时，`connector/src/agent.ts` 负责维持那条连接。它从 connector 主动向 Admin 发起 WebSocket，带上 Bearer token，断线后按 1 秒、2 秒、4 秒的指数退避重连，上限一分钟，并且每次在 0.5 到 1.5 倍之间抖动，避免大量服务器同时重连造成尖峰。作业从这条连接进来，结果也从这条连接回去；未被确认的回复留在 `unacked` 里，下次连上会重发，直到 Admin 回一个 `ack`。连接稳定超过 60 秒才把重试计数清零，否则一次短暂成功就会掩盖持续的故障。

消息处理里有两处细节值得借鉴。一是幂等：同一个 job id 如果已经在跑，重复投递会被直接丢弃；如果已经跑完，就把缓存的结果再发一遍，而不是重新执行。二是错误回复也走同一条确认通道，`checkJob` 校验失败时如果还能拿到 id，就回一个带错误码的 reply，让对端知道这条消息被拒了，而不是静默吞掉。心跳由 `startBeat` 定时触发，把状态通过 `status` 回调写回本地状态记录，连接、未授权、最后错误时间都能在 `status` 命令里看到。

整体看，这个项目的结构是围绕“一个本地 harness 管住所有 agent 进程”来组织的：CLI 负责起服务和配对，前端按路由分流到主界面或配对页，工具策略层收窄 agent 能碰的东西，connector 把远程执行能力接进来。几个模块之间的契约都比较窄——`CliOptions`、`JobReply`、只读工具名集合——这让每一层都能单独测试。想做一个本地优先、多 agent 协作的桌面应用，这套分层和它对权限、重连、幂等的处理方式，是可以直接拿来参照的。源码在 GitHub 上以 Apache-2.0 发布。

## 3. impeccable：给编码代理装上设计词汇，24 个命令加 62 条确定性规则挡住 AI 味界面

[pbakaus/impeccable](https://github.com/pbakaus/impeccable) · Rust · ★ 96,562 · 今日 +2,299 · Apache-2.0

让代理写一个落地页，它常常交出同一套东西：Inter 字体、紫到蓝的渐变、卡片套卡片、彩色底上的灰字、每个标题上方一块圆角图标砖。impeccable 想解决的问题很具体——把“让它更抓眼”这类模糊指令换成代理能执行的词汇，并在代码合入前把这类套路拦下来。项目以 npm 包分发，在项目根目录跑 `npx impeccable install`，重载编码工具后执行 `/impeccable init`（Codex 里用 `$impeccable init`）。命令要带上目标才有效果，比如 `/impeccable critique the pricing cards`，单个区块被仔细审视，比整页扫一眼更容易得到可用结果。

24 个命令分成几组。Steer 组负责方向：`bolder` 放大过于保守的设计，`quieter` 压低过吵的页面，`distill` 删掉页面不需要的东西，`colorize`、`typeset`、`layout` 分别处理配色、字体层级和间距节奏，`animate`、`delight`、`overdrive` 从过渡反馈一路走到着色器与弹簧物理。Review 组里 `critique` 按可用性启发式打分并排出修复顺序，`audit` 检查无障碍、性能、主题和响应式，发现项按 P0 到 P3 分级。Finish 组的 `polish`、`harden`、`clarify`、`adapt`、`optimize`、`onboard` 覆盖上线前最后一轮打磨。命令可以固定，`/impeccable pin audit` 之后直接用 `/audit`。

上下文靠两个文件维持。`init` 读代码，只问它推不出来的事——产品给谁用、要做什么、有哪些约束——然后写 `PRODUCT.md`，后续每条命令都读它。`document` 把现有视觉体系写进 `DESIGN.md`，让改动留在品牌轨道上。这套设计值得借鉴的地方在于：把“设计品味”从提示词里抽出来，变成项目里可版本化的文件，代理每次开工先读同一份事实，而不是靠对话历史里零散的形容词。

![pbakaus/impeccable 代码结构](./images/github-daily-2026-10-30/03-impeccable-architecture.png)

检测器是项目里最硬的部分。62 条确定性规则，不用 LLM，也不需要 API key。它有三种跑法：装进代理后，设计钩子扫描代理改过的每个 UI 文件，在代理宣布完成前把发现项递回去——README 说大部分套路是在这里被抓住的，因为不装钩子，检测器只在有人想起来时才跑；也可以在 CI 或终端里跑 `npx impeccable detect src/`，或对渲染后的页面跑 `npx impeccable detect https://example.com`，后者用本机已装的 Chrome 或 Edge。

Rust 工作区是引擎本体，`Cargo.toml` 里 `cargo build --release -p impeccable` 产出的二进制由启动脚本调用。真正的入口是 `crates/cli/src/main.rs`，它只做一件事：把每个子命令当成一个动词路由出去，动词 crate 各自暴露 `run(args, io) -> i32` 返回退出码，自己从不调 `std::process::exit`，退出码和流刷新统一在这一个文件里决定。`detect`、`ignores`、`skills`、`context`、`critique-storage`、`hook`、`live` 等都在这个 match 里分派；以路径、URL 或 flag 开头的第一个参数会被当作检测目标，对应 `npx impeccable src/` 这种简写。

URL 检测的路径值得细看。`crates/browser/src/snapshot_engine.rs` 的注释说明了演进：早期把 WebAssembly 检测包注入页面、在页面内跑规则，需要 `Page.setBypassCSP` 才能让页面的 CSP 不拒绝 `WebAssembly.Module`；现在只注入纯 JS 的快照生产者 `browser-bundle/15-snapshot.js`，把页面序列化成 JSON，规则核心在本进程里对 `SnapshotDom` 原生执行。严格 CSP 的站点因此可以在不绕过 CSP 的情况下被扫描，页面里被拦下的内联脚本仍然被拦。快照答不了的两件事走 CDP 补：命中测试由 `resolve_needs` 向实时页面取点后重跑到不动点，视觉对比度的图片加载与像素读取通过 `__impIO` 完成。

快照之后还有几何重测的取舍。`recapture_geometry` 只重新测量滚动相关的几何——`getBoundingClientRect`、直接文本矩形、`scrollX`/`scrollY`——再补到基线快照的克隆上。因为 `scrollIntoView` 只移动页面，DOM 树、属性、计算样式、媒体和关键帧都不变，而视觉路径读的字段里只有这些是相对视口的，所以一次约 80 KB 的载荷替代了约 1.2 MB 的完整重拍，省掉了 `getComputedStyle` 全量扫描。元素 id 按文档顺序分配，滚动后仍然指向同一批元素，页面侧的 `__impCap` 和 `__impIO` 继续有效。

评审结果需要落盘，`crates/context/src/critique_storage.rs` 处理这件事。快照写在项目根下的 `.impeccable/critique` 目录，文件名是时间戳加目标 slug，正文带 frontmatter，记录目标身份、目标路径和 `closed` 标记。目标身份对 URL 取 origin 加去掉尾部斜杠的路径，对本地文件取解析后的绝对路径，再配一个 sha256 指纹，用来判断两次评审是不是同一个对象。`read_newest_snapshot_for_identity` 按身份过滤后取最新一份，`close_snapshot` 把结论标记为已关闭。live 模式则把迭代搬回浏览器：打开运行中的开发服务器，叠一层覆盖层，选中元素、挑一个方向，变体就地热替换，接受后写回源码，支持 Vite、Next、SvelteKit、Astro、Nuxt 和纯 HTML；它只改本地检出，应用文案修改时会以你的权限运行 `package.json` 里可选的 `impeccable:manual-edit-validate` 脚本。npm 启动器 `cli/bin/cli.js` 也值得一提：它按 `$IMPECCABLE_BIN`、平台可选依赖、版本化用户缓存、下载的顺序找二进制，缓存和下载都要对 `engine-checksums.txt` 校验，没有记录摘要就拒绝下载，哈希不匹配就不写缓存。

## 4. OpenBot：每个 AI 同事独享一台带浏览器和文件的计算机，动作先决策后留痕

[CopilotKit/OpenBot](https://github.com/CopilotKit/OpenBot) · TypeScript · ★ 8,532 · 今日 +707 · MIT

你在聊天框里让一位“同事”去供应商门户核对发票，它没有直接调 API，而是打开自己的 Chromium，用独立登录态进入页面，翻到订单行，把结果截图发回来。整个过程里，它想点“提交付款”时被拦下，等你在审批卡片上点同意才继续。OpenBot 把这种协作做成了可克隆的模板：每个 Bot 分到一台容器化计算机，浏览器、文件、工具都在里面，而所有对计算机的操作都先经过一个网关，决定能不能做，做完再落一条审计记录。

它要解决的核心问题是授权边界。普通 agent 拿到工具就一路执行，出了事只能翻日志；OpenBot 把每个工具调用都变成一次“请求—决策—执行—记录”的往返。网关先解析目标是谁的计算机、哪个文件、哪个 MCP 服务，再对照策略判断放行还是拒绝，拒绝时直接说出触犯了哪条规则。这样浏览器动作、文件读写、外部服务调用走同一条路径，策略只需要写一遍。

接入一个 agent 的成本被压到协议层。任何说 AG-UI 的端点都能成为 Bot，`agent-langgraph/src/index.ts` 就是典型：它启动一个 Bun 服务，从 `shared/model-providers` 读出 provider 和 model，按名字构造 `ChatAnthropic`、`ChatGoogleGenerativeAI` 或 `ChatOpenAI`，再把工具绑定到模型上。模型选择、密钥变量、base URL 都来自同一份注册表，换供应商只是改配置，流式循环和消息翻译交给框架集成维护。

![CopilotKit/OpenBot 代码结构](./images/github-daily-2026-10-30/04-openbot-architecture.png)

LangGraph 适配里有个细节值得看：工具循环现在跑在 Bot 进程内，而不是浏览器里。`buildGraph` 建了一个 `answer` 节点和一个 `tools` 节点，模型发出工具调用后，只有属于“部署自己的工具”（由 `openbotDeploymentTools` 标记）才会真正执行，执行方式是 `callTool` 把请求 POST 回 `OPENBOT_TOOL_URL`，带上部署签发的 `openbotRun` 断言。凡是面向前端渲染的组件或需要人回答的决策，`callsTheSurface` 判定后直接结束本轮，由界面画出来或等人点，下一轮再带着结果继续。这样无人值守的定时任务和嵌入场景才成立。

计算机这一侧由 `agent-computer` 承担。`src/authorisation.ts` 是浏览器进程前面的第一道门：它用常量时间比较校验 `x-openbot-computer-token`，WebSocket 流因为不能设升级头，额外接受查询参数里的 token；`/health` 是唯一免鉴权路径，编排器靠它探活。同一个文件里还有一张 `ACTING_PATHS` 清单，列出 `/navigate`、`/click`、`/type`、`/exec`、`/files/write` 等真正会动计算机的路径，人接管方向盘时这些一律拒绝，而 `/files/read` 和 `/files/list` 保持开放，让被停下的 Bot 还能读自己的笔记解释刚才在做什么。

`src/action-barrier.ts` 则管住“正在执行的动作”。它不排队也不重放：`enter()` 同步放行并返回释放函数，`close()` 之后新动作直接被拒，`drain(timeoutMs)` 等到活跃计数归零才让人接管，超时就报错说还有动作没结束。这个设计让“人接管”不是一句口号——要么等当前动作收尾，要么明确告诉用户为什么接不了。审批不是事后告警，而是执行路径上的一个节点，规则本身在 `app/src/lib/boundaries/rules.ts` 里描述，团队可以按 Bot 或按工具粒度收紧。

浏览器怎么启动由 `src/browser-runtime.ts` 决定，它把后端、通道、有头无头、虚拟显示和是否允许 `exec` 收成一个 `BrowserRuntime` 对象。默认 `managed` 后端在 Linux 上跑有头 Chromium，窗口送进容器内的 X server，外面看不到，但 Cloudflare 一类挑战不会因为 `HeadlessChrome` 标记而一眼识破；开发者在 Mac 或 Windows 上直接跑则保持无头，免得桌面弹窗。`local-chrome` 后端强制有头并指向 `127.0.0.1`，同时关掉 `exec`，因为那是人自己的 Chrome。`src/recorder.ts` 处理另一件容易漏的事：人自己的浏览器打开时必须已经带上 OpenBot Recorder，它在每次打开前重新读 `OPENBOT_RECORDER_DIR` 下的 `manifest.json`，检查 Manifest V3、service worker 文件存在、`key` 字段非空，再用 `extensionIdFromKey` 从公钥 DER 算出固定扩展 ID，这样原生消息宿主和服务端白名单认的是同一个 ID，不会随目录路径漂移。

界面层把“同事在工作”变得可看。`app/src/components/computer/live-screen.tsx` 展示 Bot 的实时屏幕，`take-the-wheel.tsx` 允许人接管，`needs-you.tsx` 把需要人决定的事集中起来。频道侧 `app/src/components/channels/tool-boundary.tsx` 和 `tool-activity.tsx` 把工具调用画进对话流，用户看到的不是一段散文，而是带状态的组件。审计表格在 `app/src/components/audit/audit-table.tsx`，每条记录对应一次被决策过的动作。部署上，根 `package.json` 把各 workspace 设为私有，Docker Compose 拉起 PostgreSQL 和各个 Bot，数据留在自己的库里，上手需要 Docker、Bun 1.4+、一个 CopilotKit Intelligence 项目和一把模型 key。

## 5. ziwei-doushu：基于倪海厦《天纪》体系的紫微斗数排盘引擎，含四化、格局与古籍原文

[Renhuai123/ziwei-doushu](https://github.com/Renhuai123/ziwei-doushu) · TypeScript · ★ 10,931 · 今日 +1,146 · MIT

打开项目首页，填好出生年月日时和性别，点下排盘，十四主星与四化就落在十二宫里。这套流程背后是 `lib/ziwei/algorithm.ts` 在做实际的推演：它调用 `iztro` 的 `astro` 生成基础盘，再用 `lunar-javascript` 处理农历与节气四柱，最后把宫位、星曜、亮度和四化整理成 `ZiweiChart`。对于想自己搭一个排盘工具的人来说，这个仓库把算法层完整地开源了出来，而不是只给一个黑盒接口。

排盘的第一步是处理时间。出生地不同，真太阳时就不一样，`components/BirthForm.tsx` 里的 `calcTrueSolarBranch` 用经度差 `(longitude - 120) * 4` 把钟表时间换算成时辰支，表单里选完省市会实时显示“真太阳时 → 某时”。中国 1986 到 1991 年实行过夏令时，`lib/ziwei/dst-cn.ts` 里的 `chinaDSTSpan(year)` 能查某年的起止，但它只判定、不自动扣除；`lib/ziwei/clock-adjust.ts` 负责把钟表读数换成标准时间，跨日的情况留给调用方处理。这种把“判断”和“改写”拆开的做法，在需要保留原始输入的场景里很实用。

时间确定之后，农历公历互转交给 `lib/ziwei/lunar-solar.ts`，闰月边界做了 clamp。`algorithm.ts` 里的 `resolveEffectiveLunarDate` 支持 `split`、`next-month`、`prev-month`、`origin-month` 四种闰月策略，默认走 `prev-month`。节气四柱用 `getEightChar()` 精确到立春时刻，非节气四柱则按农历年、农历月重算，两套口径分开输出，避免立春当天凌晨出生的人被算进下一年。

![Renhuai123/ziwei-doushu 代码结构](./images/github-daily-2026-10-30/05-ziwei-doushu-architecture.png)

起盘的核心在 `generateChart`，它输出的是宫位、星曜、亮度和四化这些结构化数据。亮度默认取《斗数全书》，`algorithm.ts` 里有一张 `DEFAULT_BRIGHTNESS` 表，按寅起索引逐宫列出十四主星和辅星的庙旺利陷；想换流派可以调 `setBrightnessSchool('QS' | 'XD1' | 'ZZ' | 'XD2')`，`school-data.ts` 和 `school-tables.generated.ts` 存着对照表。四化单独放在 `lib/ziwei/sihua.ts`，不会发生的四化组合在数据层面就被排除了。

格局识别由 `lib/ziwei/patterns.ts` 完成，紫府同宫、杀破狼、机月同梁这些经典组合会被自动检出，辅弼夹命、日月夹命这类特殊结构也有对应判断。十二神煞在 `lib/ziwei/shier-shen.ts`，运限上下文（含童限）在 `lib/ziwei/yunxian-context.ts`。这些模块彼此独立，想只取排盘结果、不要格局分析，完全可以只调 `generateChart`。

古籍部分走的是另一条路。`lib/classics/index.ts` 把《骨髓赋》《紫微斗数全书》《紫微斗数全集》打包成静态 JSON，`ALL_BOOKS` 是入口，`searchClassics(query, limit)` 做子字符串匹配，命中后截取前后各 40 字做上下文，用 `<mark>` 标出关键词。没有数据库、没有网络请求，适合在服务端渲染时直接调用。`getParagraphById` 可以按段落 id 反查所属书和章节，做引证跳转很方便。

倪海厦的教学内容集中在 `lib/nihai/` 下。`index.ts` 统一导出天纪、地纪、人纪三块，`tianji.ts` 里有 `TIANJI_QUOTES` 和 `TIANJI_STATS`，`renji.ts` 收录了针灸经验、汉唐方和经典配方，`diji.ts` 是未完成的地理志部分。`NI_HAIXIA_BIO` 把生平、师承、著作体系整理成结构化对象，`SANJI_CATEGORIES` 则给前端导航用。这些数据是静态的，适合做知识库页面或检索。

前端是 Next.js App Router 结构。`components/ChartBoard.tsx` 用 4×4 网格摆十二宫，`BRANCH_GRID_POS` 把地支映射到行列，中央区域显示命宫、身宫、五行局和当前大限。点选宫位时，`getSanFangSiZheng` 算出本宫、对宫和两个三合宫，再用 SVG 虚线画出三方四正。`TimeNav` 负责本命、大限、流年三种视图切换，`buildSiHuaOverlay` 按当前大限或流年的天干叠加四化标记。回归测试放在 `scripts/regression/` 下，`npm test` 一条命令跑完十条用例，覆盖夏令时、立春边界、时辰索引、双四化同宫这些容易出错的点。

这五个项目放在一起看，有意思的地方在于它们都不太相信“模型自己会处理好”。记忆要压缩和检索，bot 要隔离，界面要规则兜底，计算机操作要过网关，排盘要自己算星曜和四化。模型负责理解和生成，剩下的边界、状态与可追溯性，仍然得靠代码来兜。如果你正在给代理加长期上下文、做多 bot 协作，或者只是想找一个结构清晰的排盘实现，这几个仓库都值得翻一翻源码。
