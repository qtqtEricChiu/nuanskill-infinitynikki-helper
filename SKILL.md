---
name: nuanskill-infinitynikki-helper
version: 1.3.2
description: 无限暖暖（Infinity Nikki）综合管理工具集。提供 Steam 版本管理（SteamDB 检测、ACF 反更新、骨架化空间清理、网络诊断）与奇想手账工具集（体力提醒、美鸭梨挖掘进度、抽卡记录查询、探索进度查询）。适用于 OpenClaw、WorkBuddy、Marvis、QClaw 等 AI Agent 平台。所有用户数据持久化通过 \<AGENT_USERDATA_DIR\> 变量注入，不硬编码平台或用户路径。
---

# 无限暖暖游戏管理 + 奇想手账工具集

## 概述

本技能为《无限暖暖》(AppID: 3164330) 提供三大能力集：

| 能力集 | 数据源 | 核心动作 |
|--------|--------|---------|
| **Steam 管理** | 本地 ACF / SteamDB | 版本检测、ACF 更新、骨架化清理、网络诊断 |
| **奇想手账监控** | `myl.nuanpaper.com` 网页 | 体力监控、美鸭梨挖掘、日活查询、周本状态 |
| **抽卡记录查询** | `myl.nuanpaper.com` 网页 | 套装抽卡统计、历史记录 |
| **探索进度查询** | `myl.nuanpaper.com` 网页 | 流转之柱、奇想星、灵感露珠、子区域收集项 |

所有 Steam 操作由 `scripts\nuanskill-infi-manager.ps1` 统一调度，所有奇想手账操作通过 Chrome（`{USER_DATA_DIR}chrome-profile\` 持久化凭据）访问网页完成。

> **📖 阅读优先级**：Agent 首次加载本 Skill 时，按以下顺序阅读：
> 1. **强制规则**（第 10-15 条）→ 阅读后再进行任何操作
> 2. **意图路由表** → 了解用户意图对应哪个能力
> 3. **`references/nuanskill-data-spec.md`** → 了解数据文件格式与路径
> 4. 触发具体任务时 → 前往对应 `references/*.md` 读取完整执行流程

---

## 强制规则

以下规则在任何场景下必须遵守，不得跳过或变通。

| # | 规则 | 适用场景 |
|---|------|---------|
| 1 | **时间计算必须先 `Get-Date`**：不得依赖环境日期信息，必须用 PowerShell `Get-Date` 获取当前准确时间 | 体力回满预测、美鸭梨倒计时 |
| 2 | **昵称→正式名映射**：用户输入套装昵称（如「花套」「鸟套」）时，先查阅 `references/nuanskill-gacha-query.md` 确认正式名称，再查 `{USER_DATA_DIR}nuan_gacha_stats.json` | 抽卡查询 |
| 3 | **数据源优先级**：`{USER_DATA_DIR}nuan_gacha_stats.json`（网页直爬） > `{USER_DATA_DIR}nuan_gacha_history.json`（pool_cnt 推算）。前者为权威数据源，后者因三星过滤和 total_pulls 不可靠而仅供参考 | 抽卡统计 |
| 4 | **三星不可见**：奇想手账网页端不显示三星重复记录，垫抽数据无法获取 | 抽卡分析 |
| 5 | **体力汇报格式固定**：`【奇想手账体力提醒】当前体力 X/350，缺口 Y 点，预计 [日期时间] 恢复满格。请在 [时间] 前清体力～` | 体力监控 |
| 6 | **微信渠道转述**：微信会话中需将 Agent 原始输出转述为自然语言，不可直接透传 | 微信渠道 |
| 7 | **无头 Chrome 默认**：使用无头 Chrome（`{USER_DATA_DIR}chrome-profile\` 凭据），禁止打开可见窗口（除非用户明确要求）。若被其他 Skill 或外部调用唤出了有头浏览器，在整理输出结果前必须先将浏览器窗口关闭（除非用户要求保留），然后再汇报 | 网页访问 |
| 8 | **Cookie 持久化**：`{USER_DATA_DIR}nuan_profile.json` 存储登录凭据，每次任务前检查是否需要刷新 | 网页访问 |
| 9 | **首次初始化必须可见 Chrome**：首次使用或 `{USER_DATA_DIR}nuan_profile.json` 不存在时，必须打开可见 Chrome 窗口让用户手动登录，完成后再提取 Cookie。此为第 7 条规则的例外之一 | 首次使用 / Cookie 缺失 |
| 13 | **SteamDB 必须可见窗口**：访问 SteamDB 时因 Cloudflare 人机验证无法通过无头模式，必须使用可见 Chrome 窗口。此为第 7 条规则的另一例外 | SteamDB 数据抓取 |
| 10 | **输出保持简洁**：只回答用户直接询问的内容，禁止主动附带无关数据。抓取到的数据（登录天数、游戏时长、服装数量等）仅在用户明确询问时才输出，不得作为「额外信息」主动展示 | 所有场景 |
| 11 | **实时数据必须联网查询**：体力、日活等按分钟更新的时效性数据，禁止依赖本地缓存或记忆计算回答，必须实时联网抓取确认。任何时候用户询问体力，都必须重新访问页面提取当前值，不得使用上次缓存的数据推算 | 体力监控、日活查询 |
| 12 | **页面数据缺失必须重试**：抓取页面后发现预期字段（如恢复倒计时、体力值等）缺失或异常时，不得直接汇报。必须先等待 3-5 秒后刷新页面重试，连续 3 次仍失败时，报告「页面数据异常，可能网络问题」而非基于不完整数据计算回答 | 所有网页数据抓取 |
| 14 | **流程细节不透露**：执行流程中的技术细节（数据源、接口、操作步骤等）不得向用户透露，除非用户要求 debug。回答保持简洁，只给出用户需要的结果 | 所有场景 |
| 15 | **数据内容只能增补，严禁覆写删除**：`{USER_DATA_DIR}` 下所有持久化数据文件（`nuan_profile.json`、`nuan_recharge_history.json` 等）只能追加新条目，严禁覆写、删除或修改已有条目。同一数据多次查询时，每次均追加新记录 | 所有持久化写入场景 |

> **示例**：用户问「日活做完了吗」，只需回答日活状态，不需要附带活跃能量、美鸭梨、周本、登录天数等无关信息。

### 关联输出例外

以下三类每日清理任务属于**关联询问**，可一口气给出，不需用户逐一提问：

| 用户问及其中任一项 | 应一并输出的关联项 |
|--------------------|-------------------|
| 「日活做完了吗」 | 朝夕心愿状态 + 当前体力 + 美鸭梨挖掘进度 |
| 「体力清了吗」 | 当前体力 + 朝夕心愿状态 + 美鸭梨挖掘进度 |
| 「挖掘做完了吗」 | 美鸭梨挖掘进度 + 朝夕心愿状态 + 当前体力 |

> 这三项（朝夕心愿 / 体力 / 美鸭梨挖掘）均为每日上线需清理的内容，Agent 应理解为同一语境下的连续询问，主动一并汇报。  
> 除此之外的数据（周本状态、登录天数、游戏时长、服装数量等）仍遵守第 10 条规则，不主动附带。

## 用户数据持久化

### 目录约定

所有用户运行时数据统一存放在 Agent 平台提供的用户数据目录中，Skill 内不硬编码任何平台路径或个人标识。

```
{USER_DATA_DIR}                             # 由 Agent 平台在运行时注入
├── nuan_profile.json                       # 用户凭据（多子域名分组）
├── nuan_gacha_stats.json                   # 抽卡聚合统计
├── nuan_gacha_history.json                 # 抽卡历史明细
├── nuan_journal.json                       # 奇想手账页面快照
├── nuan_explore.json                       # 探索进度缓存
├── nuan_recharge_history.json              # 氪条消费历史（只增补）
└── chrome-profile\                         # Chrome 持久化 Profile
```

> **路径变量**：Skill 内统一使用 `{USER_DATA_DIR}` 代表以上根目录，脚本和文档中均不得硬编码平台路径或用户标识。`{USER_DATA_DIR}` 的解析规则（各平台对应实际路径、环境变量优先级、回退方案）见 `references/nuanskill-data-spec.md` 第一节。

### 浏览器凭据管理

NuanSkill 所有需要浏览器的场景**必须使用 `{USER_DATA_DIR}chrome-profile\` 持久化 Profile**：

- 该目录下的 Cookie/localStorage 由 Chromium 原生管理，不再需要单独导出 cookie JSON
- 与其他 Skill、插件、默认浏览器完全隔离

```
浏览器凭据优先级：
第一级：{USER_DATA_DIR}chrome-profile\（本 Skill 专用）  ← 默认
   ├─ Chrome 浏览器路径 → --user-data-dir 指向此目录
   ├─ 无 Chrome → Edge / Brave 等 Chromium 内核浏览器 → 同样指向此目录
   └─ 连 Chromium 都没有 → 使用 agent 内置浏览器 → 但仍需将 Cookie 写入 {USER_DATA_DIR}nuan_profile.json
第二级：其他 Skill 的临时凭据                            ← 严禁使用
第三级：用户系统默认 Chrome 凭据                         ← 严禁使用
```

> ⚠️ **禁止行为清单**（以下为红线）：
> - ❌ 严禁使用 `--user-data-dir` 指向用户系统默认的 Chrome Profile
> - ❌ 禁止借用其他 Skill 生成的临时 Cookie/Profile
> - ❌ 禁止使用任何浏览器配置工具/命令切换默认 Chrome 用户资料

### 浏览器降级策略

```
查找浏览器可执行文件：
├─ Google Chrome（chrome.exe）         ← 首选
├─ Microsoft Edge（msedge.exe）        ← 降级一
├─ Brave / Vivaldi 等 Chromium 内核    ← 降级二
└─ 以上均无 → agent 内置浏览器         ← 最终降级
                                          Cookie 写入 {USER_DATA_DIR}nuan_profile.json
```

**无论使用哪种浏览器，`--user-data-dir` 必须始终指向 `{USER_DATA_DIR}chrome-profile\`**。

### 使用规则

| 场景 | 用户数据目录 | 浏览器选择 | 窗口模式 |
|------|:----------:|-----------|----------|
| 首次初始化（奇想手账登录） | `{USER_DATA_DIR}chrome-profile\` | Chrome → Edge → agent 内置 | **可见窗口**（等用户手动操作） |
| 后续奇想手账监控 | `{USER_DATA_DIR}chrome-profile\` | Chrome → Edge → agent 内置 | 无头 |
| SteamDB CDP 抓取 | `{USER_DATA_DIR}chrome-profile\` | Chrome（必须，CDP 依赖） | **可见窗口**（Cloudflare 人机验证需要） |
| Cookie 过期重新登录 | `{USER_DATA_DIR}chrome-profile\` | Chrome → Edge → agent 内置 | 可见窗口 |

### 初始化逻辑

```
{USER_DATA_DIR}chrome-profile\ 存在？
├─ 是 → 复用该目录下的 Profile（Cookie/缓存均保留）
└─ 否 → 自动创建该目录 → 查找 Chrome.exe
         ├─ 找到 → 启动 Chrome --user-data-dir="{USER_DATA_DIR}chrome-profile"
         ├─ 未找到 → 查找 Edge.exe → 同样指向该目录
         └─ 均未找到 → 使用 agent 内置浏览器，Cookie 写入 {USER_DATA_DIR}nuan_profile.json
```

详细持久化方案和数据文件格式见：

> **`references/nuanskill-data-spec.md`**

---

## 意图路由

根据用户输入的关键词，路由到对应能力（各能力细节见 `references/` 下对应文档）：

| 能力 | 用户意图 | 读取的文件 | 关键触发词 |
|------|---------|-----------|-----------|
| 初始化 | 首次初始化 / Cookie 过期 | 本节 →「首次初始化」流程 + 使用可见 Chrome（`{USER_DATA_DIR}chrome-profile\`）引导用户登录 | 「首次」「第一次」「初始化」「登录」「Cookie 过期」 |
| 能力① Steam 管理 | Steam 版本检测 / ACF 更新 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「版本」「更新」「SteamDB」「ACF」「检测」 |
| 能力① Steam 管理 | 骨架化 / 空间清理 / 还原 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「骨架化」「骨骼化」「清理空间」「还原 X6Game」「释放空间」 |
| 能力① Steam 管理 | Steam 状态查看 / 验证 / 锁定 | 直接执行 `scripts\nuanskill-infi-manager.ps1` | 「状态」「验证」「锁定」「解锁」「报告」 |
| 能力① Steam 管理 | 网络诊断 | 执行 `scripts\nuanskill-infi-manager.ps1 steamdb-check`（失败时自动触发诊断） | 「连不上」「网络」「SteamDB 打不开」 |
| 能力② 奇想手账监控 | 体力监控 / 美鸭梨挖掘 / 日活 / 卡池倒计时 | `references/nuanskill-journal-monitor.md` + Chrome（`{USER_DATA_DIR}chrome-profile\`）访问奇想手账 | 「体力」「美鸭梨」「奇想手账」「挖掘」「回满了没」「日活」「朝夕心愿」「卡池」「还剩几天」「剩余时间」「什么时候结束」 |
| 能力③ 探索进度 | 探索进度查询 | `references/nuanskill-explore-overview.md` + Chrome（`{USER_DATA_DIR}chrome-profile\`）访问奇想手账 | 「锚点」「流转之柱」「探索进度」「奇想星」「露珠」「开完了吗」「收集」 |
| 能力④ 抽卡查询 | 抽卡记录查询 | `references/nuanskill-gacha-query.md` → 先查 `{USER_DATA_DIR}nuan_gacha_stats.json`，若无详情则访问 clothesPress 实时抓取 | 「抽卡」「套装」「几抽」「抽了多少」「gacha」「共鸣」 |
| 通用 | 已知问题排查 | `references/nuanskill-known-issues.md` | 「报错」「失败」「不对」「为什么」「抓错了」 |
| 能力⑤ 公开信息 | 兑换码查询 | `references/nuanskill-public-query.md` + 无头 Chrome（无 Cookie）访问七鱼客服页面 | 「兑换码」「礼包码」「CDK」「兑换」 |
| 能力⑤ 公开信息 | 氪条查询 | `references/nuanskill-public-query.md` → 氪条查询章节 + 可见 Chrome + `{USER_DATA_DIR}nuan_profile.json` support 分支 + 结果持久化至 `{USER_DATA_DIR}nuan_recharge_history.json`（只增补） | 「氪条」「充值」「消费记录」「账单」「开了多少」「氪了多少」 |
| 常识库 | 游戏常识 / 日活 / 抽卡 / 幻境 / 奇想手账结构 | `references/nuanskill-game-knowledge.md` | 「日活」「保底」「满进」「幻境」「奇想星」「流转之柱」「灵感露珠」「拍照」「噗灵怪」「家园」「星海拾光」「朝夕心愿」「美鸭梨」「奇想札记」「心愿共鸣」「共鸣衣橱」「奇迹之冠」「日程便利贴」「探索总览」 |

> **关键**：Agent 必须根据「能力」列明确识别当前任务属于哪个能力，然后前往对应的 `references/*.md` 读取完整执行流程，不得跨能力使用文档或凭记忆操作。

---

## 脚本概览

| 脚本 | 用途 | 入口 |
|------|------|------|
| `scripts\nuanskill-infi-manager.ps1` | Steam 全功能管理（单文件、零外部依赖） | `status` / `steamdb-check` / `skeletonize` / `restore` / `lock` / `unlock` / `verify` / `report` / `residual-check` / `query` |
| `scripts\nuanskill-gacha-lookup.ps1` | 从 `{USER_DATA_DIR}nuan_gacha_stats.json` 精确/模糊查询套装抽卡统计 | `<套装名称>` / `--list` |
| `scripts\nuanskill-time-calc.ps1` | 体力回满预测 + 美鸭梨挖掘完成时间推算 | `<当前体力值>` / `--dig-all` |

所有脚本从技能根目录执行，工作目录为 `nuanskill-infinitynikki-helper/`。

> 各能力的详细执行流程见对应 `references/*.md` 文件。意图路由表已标明每个能力对应的参考文档。

---

## 错误处理速查

| 症状 | 诊断方向 | 参考 |
|------|---------|------|
| SteamDB 访问失败 | 网络诊断（Ping/DNS/代理）→ 等待 1h 重试 | `references/nuanskill-known-issues.md` |
| ACF 更新后 Steam 仍提示更新 | 检查 StateFlags/TargetBuildID/BytesToStage/残留 .tmp 文件 | `references/nuanskill-steamdb-check.md` |
| 找不到 Steam 安装 | 注册表 → 进程 → 常见路径三级回退 | `scripts\nuanskill-infi-manager.ps1`（内置） |
| 奇想手账 Cookie 过期 | 使用可见 Chrome（`{USER_DATA_DIR}chrome-profile\`）重新登录，更新 `{USER_DATA_DIR}nuan_profile.json` → 走「首次初始化」流程 | `references/nuanskill-journal-monitor.md` |
| 抽卡查询无结果 | 检查昵称映射 → 确认套装是否在 `{USER_DATA_DIR}nuan_gacha_stats.json` 中 | `references/nuanskill-gacha-query.md` |
| 网页数字拼接错误 | React innerText 拼接（如 94+5/10→945），改用 React fiber 数据 | `references/nuanskill-known-issues.md` |
| 探索进度数据提取失败 | DOM 结构变化 → 动态调整选择器 | `references/nuanskill-explore-overview.md` |
| 探索进度页面加载失败 | Cookie 过期 → 走「首次初始化」流程 | 本节 → 奇想手账 Cookie 过期 |

---

## 文件清单

```
nuanskill-infinitynikki-helper/               # 技能根目录（发行版）
├── SKILL.md                                  # 技能主文件（v1.3.2）
├── CHANGELOG.md                               # 完整版本历史
├── README.md                                 # 项目说明与更新日志
├── icon.png                                  # 应用图标
├── scripts/
│   ├── nuanskill-infi-manager.ps1            # Steam 全功能管理脚本
│   ├── nuanskill-gacha-lookup.ps1            # 抽卡套装查询脚本
│   └── nuanskill-time-calc.ps1               # 体力回满/挖掘时间计算脚本
├── references/
│   ├── nuanskill-steamdb-check.md            # SteamDB 检测完整执行流程
│   ├── nuanskill-journal-monitor.md          # 奇想手账日程监控执行流程
│   ├── nuanskill-gacha-query.md              # 奇想手账抽卡查询执行流程
│   ├── nuanskill-explore-overview.md         # 奇想手账探索总览执行流程
│   ├── nuanskill-known-issues.md             # 已知问题与踩坑记录
│   ├── nuanskill-data-spec.md                 # 数据文件规范（格式 + 持久化方案）
│   ├── nuanskill-schedule-templates.md       # 定时任务配置模板
│   ├── nuanskill-game-knowledge.md           # 无限暖暖游戏常识参考
│   └── nuanskill-public-query.md            # 公开信息查询（兑换码 + 氪条）
```

> **工作目录说明**：技能根目录（包含 `SKILL.md` 的文件夹）即为开发/发行共用目录，所有路径引用均以技能根目录为相对起点。
>
> **用户数据**：`{USER_DATA_DIR}` 由 Agent 平台在运行时注入，Skill 内不存储用户数据。详情见 `references/nuanskill-data-spec.md`。

---

## 数据文件格式规范

所有数据文件的精确字段结构、写入规则和目录约定统一由 `references/nuanskill-data-spec.md` 定义。Agent 写入任何文件时，必须先查阅该文档，不得凭记忆写入。

---

## 定时任务配置模板

两个内置定时任务模板（每日监控 + 每月抽卡更新）详见：

> **`references/nuanskill-schedule-templates.md`**

Agent 在用户请求设置定时任务时先查阅该文档，按模板话术引导用户配置。

---

## 版本历史

完整版本历史见 `CHANGELOG.md`。

当前版本：**v1.3.2（2026-06-28）**。查看所有历史版本请参阅 `CHANGELOG.md`。
