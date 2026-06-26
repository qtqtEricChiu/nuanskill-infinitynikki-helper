---
name: nuanskill-infinitynikki-helper
version: 1.1.0
description: 无限暖暖（Infinity Nikki）综合管理工具集。提供 Steam 版本管理（SteamDB 检测、ACF 反更新、骨架化空间清理、网络诊断）与奇想手账工具集（体力提醒、美鸭梨挖掘进度、抽卡记录查询、探索进度查询）。适用于 OpenClaw、WorkBuddy、Marvis、QClaw 等 AI Agent 平台。
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

所有 Steam 操作由 `scripts\nuanskill-infi-manager.ps1` 统一调度，所有奇想手账操作通过 browser agent 访问网页完成。

---

## 初次使用引导

### 首次初始化（仅需一次）

> **触发条件**：`user-data/nuan_user_profile.json` 不存在或 Cookie 已失效。

首次使用时，Agent 会引导用户完成以下初始化步骤：

```
1. 打开可见 Chrome 窗口（覆盖强制规则第 7 条的无头默认）
2. 导航到 https://myl.nuanpaper.com/tools/journal/login
3. ⏸️  等待用户手动完成登录（涉及验证码等人工环节）
4. 登录成功后提取 Cookie（momoToken / momoOpenid / momoNid / momoVisitor）
5. 将 Cookie 保存到 user-data/nuan_user_profile.json
6. 关闭该可见 Chrome 窗口
```

> 完成后，后续所有奇想手账任务恢复无头浏览器 + Cookie 注入模式。

### 抽卡记录首次爬取说明

> **重要**：第一次爬取抽卡记录时，由于需要遍历所有历史抽卡页面，耗时较长（通常需要 5-15 分钟，具体取决于抽卡数量）。
> 
> Agent 必须在开始爬取前告知用户：
> - 预计耗时：约 X 分钟（根据历史记录数量估算）
> - 爬取过程中请勿关闭浏览器窗口
> - 爬取完成后数据将保存到本地，后续查询无需重新爬取
> 
> 爬取完成后，数据保存至 `user-data/nuan_gacha_stats.json`，后续查询将直接读取本地数据，无需重新爬取。

### 探索进度数据初始化

首次查询探索进度时，Agent 会爬取 `myl.nuanpaper.com/tools/journal` 的「探索总览」标签页，并将数据保存至 `user-data/nuan_explore_data.json`。
探索数据变化缓慢，建议定期更新（可随每日定时任务一起执行）。

---

## 强制规则

以下规则在任何场景下必须遵守，不得跳过或变通。

| # | 规则 | 适用场景 |
|---|------|---------|
| 1 | **时间计算必须先 `Get-Date`**：不得依赖环境日期信息，必须用 PowerShell `Get-Date` 获取当前准确时间 | 体力回满预测、美鸭梨倒计时 |
| 2 | **昵称→正式名映射**：用户输入套装昵称（如「花套」「鸟套」）时，先查阅 `references/nuanskill-gacha-query.md` 确认正式名称，再查 `user-data/nuan_gacha_stats.json` | 抽卡查询 |
| 3 | **数据源优先级**：`user-data/nuan_gacha_stats.json`（网页直爬） > `user-data/nuan_gacha_history.json`（pool_cnt 推算）。前者为权威数据源，后者因三星过滤和 total_pulls 不可靠而仅供参考 | 抽卡统计 |
| 4 | **三星不可见**：奇想手账网页端不显示三星重复记录，垫抽数据无法获取 | 抽卡分析 |
| 5 | **体力汇报格式固定**：`【奇想手账体力提醒】当前体力 X/350，缺口 Y 点，预计 [日期时间] 恢复满格。请在 [时间] 前清体力～` | 体力监控 |
| 6 | **微信渠道转述**：微信会话中需将 browser agent 原始输出转述为自然语言，不可直接透传 | 微信渠道 |
| 7 | **无头浏览器默认**：browser agent 使用无头 Chromium + cookie 注入，禁止打开可见 Chrome 窗口（除非用户明确要求） | 网页访问 |
| 8 | **Cookie 持久化**：`user-data/nuan_user_profile.json` 存储登录凭据，每次任务前检查是否需要刷新 | 网页访问 |
| 9 | **首次初始化必须可见 Chrome**：首次使用或 `nuan_user_profile.json` 不存在时，必须打开可见 Chrome 窗口让用户手动登录，完成后再提取 Cookie。此为第 7 条规则的唯一例外 | 首次使用 / Cookie 缺失 |
| 10 | **输出保持简洁**：只回答用户直接询问的内容，禁止主动附带无关数据。抓取到的数据（登录天数、游戏时长、服装数量等）仅在用户明确询问时才输出，不得作为「额外信息」主动展示 | 所有场景 |

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

## Chrome 用户凭据管理

NuanSkill 所有需要 Chrome 浏览器的场景（奇想手账登录/监控、SteamDB 数据抓取）**共用**一个隔离的 Chrome 用户数据目录：

- **统一目录**：`Cache\chrome_temp_profile\`
- **位置**：技能根目录下的 `Cache\chrome_temp_profile\`，首次使用前目录不存在时会自动创建

### 使用规则

| 场景 | 是否使用该目录 | 窗口模式 |
|------|:---:|------|
| 首次初始化（奇想手账登录） | 必须 | **可见窗口**（等用户手动操作） |
| 后续奇想手账监控 | 必须 | 无头浏览器 + Cookie 注入 |
| SteamDB CDP 抓取 | 必须 | 无头模式优先，失败时降级可见 |
| Cookie 过期重新登录 | 必须 | 可见窗口 |

> **禁止**为 SteamDB 单独创建 `chrome-profile-steamdb` 等独立目录，统一使用 `Cache\chrome_temp_profile\`。

### 初始化逻辑

Agent 在执行任何需要 Chrome 的场景前，先判断：

```
Cache\chrome_temp_profile\ 存在？
├─ 是 → 复用该目录下的 Profile（Cookie/缓存均保留）
└─ 否 → 自动创建该目录，走首次初始化流程
```

这样 Agent 打开 Chrome 时只需一个参数：`--user-data-dir="<SKILL_DIR>\Cache\chrome_temp_profile"`，不管当前任务是登录奇想手账还是抓 SteamDB，都能复用同一个凭据空间。

---

## 意图路由

根据用户输入的关键词，路由到对应能力：

| 用户意图 | 读取的文件 | 关键触发词 |
|---------|-----------|-----------|
| 首次初始化 / Cookie 过期 | 本节 →「首次初始化」流程 + browser agent 打开可见 Chrome | 「首次」「第一次」「初始化」「登录」「Cookie 过期」 |
| Steam 版本检测 / ACF 更新 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「版本」「更新」「SteamDB」「ACF」「检测」 |
| 骨架化 / 空间清理 / 还原 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「骨架化」「骨骼化」「清理空间」「还原 X6Game」「释放空间」 |
| Steam 状态查看 / 验证 / 锁定 | 直接执行 `scripts\nuanskill-infi-manager.ps1` | 「状态」「验证」「锁定」「解锁」「报告」 |
| 网络诊断 | 执行 `scripts\nuanskill-infi-manager.ps1 steamdb-check`（失败时自动触发诊断） | 「连不上」「网络」「SteamDB 打不开」 |
| 体力监控 / 美鸭梨挖掘 / 日活 | `references/nuanskill-journal-monitor.md` + browser agent 访问奇想手账 | 「体力」「美鸭梨」「奇想手账」「挖掘」「回满了没」「日活」「朝夕心愿」 |
| 抽卡记录查询 | `references/nuanskill-gacha-query.md` + `user-data/nuan_gacha_stats.json` | 「抽卡」「套装」「几抽」「抽了多少」「gacha」 |
| 探索进度查询 | `references/nuanskill-explore-overview.md` + browser agent 访问奇想手账 | 「锚点」「流转之柱」「探索进度」「奇想星」「露珠」「开完了吗」 |
| 已知问题排查 | `references/nuanskill-known-issues.md` | 「报错」「失败」「不对」「为什么」 |

---

## 脚本概览

| 脚本 | 用途 | 入口 |
|------|------|------|
| `scripts\nuanskill-infi-manager.ps1` | Steam 全功能管理（单文件、零外部依赖） | `status` / `steamdb-check` / `skeletonize` / `restore` / `lock` / `unlock` / `verify` / `report` / `residual-check` / `query` |
| `scripts\nuanskill-gacha-lookup.ps1` | 从 `user-data/nuan_gacha_stats.json` 精确/模糊查询套装抽卡统计 | `<套装名称>` / `--list` |
| `scripts\nuanskill-time-calc.ps1` | 体力回满预测 + 美鸭梨挖掘完成时间推算 | `<当前体力值>` / `--dig-all` |

所有脚本从技能根目录执行，工作目录为 `nuanskill-infinitynikki-helper/`。

---

## 核心工作流

### 首次初始化（仅需一次）

> **触发条件**：`user-data/nuan_user_profile.json` 不存在或 Cookie 已失效。

```
1. 打开可见 Chrome 窗口（覆盖强制规则第 7 条的无头默认）
2. 导航到 https://myl.nuanpaper.com/tools/journal/login
3. ⏸️  等待用户手动完成登录（涉及验证码等人工环节）
4. 登录成功后提取 Cookie（momoToken / momoOpenid / momoNid / momoVisitor）
5. 将 Cookie 保存到 user-data/nuan_user_profile.json
6. 关闭该可见 Chrome 窗口
```

> 完成后，后续所有奇想手账任务恢复无头浏览器 + Cookie 注入模式。

### Steam 管理流程

```
1. 检查 Steam 是否运行 → 尝试关闭
2. scripts\nuanskill-infi-manager.ps1 status → 读取当前 ACF 状态
3. scripts\nuanskill-infi-manager.ps1 steamdb-check → 自动检测 + 更新 + 锁定
4. scripts\nuanskill-infi-manager.ps1 verify → 7 项验证确认
```

### 奇想手账监控流程

```
1. browser agent 访问 https://myl.nuanpaper.com/tools/journal
2. 提取体力值 + 美鸭梨挖掘数据
3. nuanskill-time-calc.ps1 计算回满时间 + 挖掘完成时间
4. 按固定格式汇报
```

### 抽卡查询流程

```
1. 用户输入套装昵称 → 查 references/nuanskill-gacha-query.md 获取正式名
2. nuanskill-gacha-lookup.ps1 查询 user-data/nuan_gacha_stats.json
3. 返回总抽数 / 平均抽数 / 部件数等统计
```

### 探索进度查询流程

```
1. browser agent 访问 https://myl.nuanpaper.com/tools/journal（无头 + Cookie 注入）
2. 切换到「探索总览」标签页（第 2 个标签）
3. 提取各区域的流转之柱、奇想星、灵感露珠、子区域收集项数据
4. 按区域分组汇报 X/Y 格式的进度
5. 将数据保存到 user-data/nuan_explore_data.json（覆盖更新）
```

> **关键**：实时查询时，Agent 应在回答用户问题的同时，将当前网页的所有探索数据保存到本地，即使部分数据不在用户询问范围内。

---

## 错误处理速查

| 症状 | 诊断方向 | 参考 |
|------|---------|------|
| SteamDB 访问失败 | 网络诊断（Ping/DNS/代理）→ 等待 1h 重试 | `references/nuanskill-known-issues.md` |
| ACF 更新后 Steam 仍提示更新 | 检查 StateFlags/TargetBuildID/BytesToStage/残留 .tmp 文件 | `references/nuanskill-steamdb-check.md` |
| 找不到 Steam 安装 | 注册表 → 进程 → 常见路径三级回退 | `scripts\nuanskill-infi-manager.ps1`（内置） |
| 奇想手账 Cookie 过期 | browser agent 重新登录，更新 `user-data/nuan_user_profile.json` → 走「首次初始化」流程 | `references/nuanskill-journal-monitor.md` |
| 抽卡查询无结果 | 检查昵称映射 → 确认套装是否在 `user-data/nuan_gacha_stats.json` 中 | `references/nuanskill-gacha-query.md` |
| 网页数字拼接错误 | React innerText 拼接（如 94+5/10→945），改用 React fiber 数据 | `references/nuanskill-known-issues.md` |
| 探索进度数据提取失败 | DOM 结构变化 → 动态调整选择器 | `references/nuanskill-explore-overview.md` |
| 探索进度页面加载失败 | Cookie 过期 → 走「首次初始化」流程 | 本节 → 奇想手账 Cookie 过期 |

---

## 文件清单

```
nuanskill-infinitynikki-helper/               # 技能根目录（发行版）
├── SKILL.md                                  # 技能主文件（v1.1.0）
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
│   └── nuanskill-known-issues.md             # 已知问题与踩坑记录
├── Cache/                                    # 运行时缓存（非版本控制）
│   └── chrome_temp_profile/                  # 统一 Chrome 用户数据目录（奇想手账 + SteamDB 共用）
└── user-data/                                # 个人配置文件（不纳入版本控制）
    ├── nuan_gacha_stats.json                 # 网页直爬的套装抽卡统计（权威）
    ├── nuan_gacha_history.json               # 历史抽卡记录（仅供参考）
    ├── nuan_journal_data.json                # 奇想手账定时抓取缓存
    ├── nuan_explore_data.json                # 探索进度缓存（流转之柱/奇想星/露珠等）
    ├── nuan_user_profile.json                # Chrome 用户 Profile（含 Cookie）
    └── nuan_session.json                     # 会话上下文
```

> **工作目录说明**：`Q:\数据\Web\NuanSkill` 是开发工作目录，包含发行版的所有文件。
> 发行版目录为 `Q:\数据\Web\nuanskill-infinitynikki-helper`，是实际分发的技能包。

> **Cache/ 说明**：运行时生成的临时数据（Chrome Profile 目录），Agent 执行任务时使用。  
> **user-data/ 说明**：个人运行时数据文件，由定时任务每日/每月更新。Agent 执行任务时从 user-data/ 读取，无需每次重新抓取。Cookie 过期时 browser agent 重新登录更新。

---

## 自动任务推荐

当用户通过 Agent 创建了与 NuanSkill 相关的自动任务（如定期更新抽卡记录）时，Agent 应主动向用户推荐一并更新其他内容：

- **定期更新抽卡记录** → 推荐同时更新探索进度数据（`nuan_explore_data.json`）
- **每日定时任务** → 推荐同时执行日程监控（体力/美鸭梨/日活）和探索进度更新
- **每月定时任务** → 推荐同时执行抽卡记录更新和探索进度更新

> **示例**：用户创建「每月 1 号更新抽卡记录」的定时任务时，Agent 应询问：「是否需要同时更新探索进度数据？这样可以保持本地数据最新。」

---

## 版本历史

### v1.1.0（当前，2026-06-26）
- **新增「探索进度查询」能力（能力三）**：支持查询各区域流转之柱（锚点）、奇想星、灵感露珠、子区域收集项进度
- 新增 `references/nuanskill-explore-overview.md`：探索总览执行流程参考
- 新增 `user-data/nuan_explore_data.json`：探索进度本地缓存
- 更新概述表格：从「两大能力集」扩展为「三大能力集」
- 意图路由表新增「探索进度查询」触发行
- 核心工作流新增「探索进度查询流程」
- 错误处理速查新增探索进度相关条目
- 文件清单新增 `README.md`、`nuanskill-explore-overview.md`、`nuan_explore_data.json`
- 新增「初次使用引导」章节：包含首次初始化、抽卡记录首次爬取说明、探索进度数据初始化
- 新增「自动任务推荐」章节：引导用户创建定时任务时一并更新相关数据
- QClaw 平台测试通过（支持设置-技能管理-本地导入或从 Github 导入）

### v1.0.1（2026-06-26）
- **新增「首次初始化」工作流**：首次使用或 Cookie 缺失时，自动弹出可见 Chrome 引导用户手动登录，完成后提取 Cookie 持久化
- 新增第 9 条强制规则：首次初始化必须可见 Chrome（第 7 条规则的唯一例外）
- 意图路由表新增「首次初始化 / Cookie 过期」触发行
- 错误处理速查的 Cookie 过期条目指向「首次初始化」流程

### v1.0.0（2026-06-25）
- **正式发布版本**：整合 Steam 管理与奇想手账两大能力集
- SKILL.md 采用 Agent Skill 标准格式（YAML front matter + 强制规则 + 意图路由表 + 错误处理速查）
- 脚本统一 `nuanskill-` 命名前缀
- 结构精简，SKILL.md 作为概括性入口，详细流程委托给 references/
- 8 条不可违反的执行规则

### 废弃版本

以下为开发迭代过程中的废弃版本，仅供参考：

- **v4.0.0** — 前一次 SKILL.md 重写版本（已废弃）
- **v3.2.0** — reference 文档统一命名阶段（已废弃）
- **v3.1.0** — 奇想手账能力整合阶段（已废弃）
- **v3.0.0** — 工具集架构重构阶段（已废弃）
- **v1.0.0** — 初始原型版本（已废弃）
