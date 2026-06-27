---
name: nuanskill-infinitynikki-helper
version: 1.3.1
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

所有 Steam 操作由 `scripts\nuanskill-infi-manager.ps1` 统一调度，所有奇想手账操作通过 Chrome（`Cache\chrome_temp_profile\` 专用凭据）访问网页完成。

---

## 初次使用引导

### 首次初始化（仅需一次）

> **触发条件**：`user-data/nuan_cookie_nuanpaper.json` 不存在或 Cookie 已失效。

首次使用时，Agent 会引导用户完成以下初始化步骤：

```
1. 打开可见 Chrome 窗口（覆盖强制规则第 7 条的无头默认）
2. 导航到 https://myl.nuanpaper.com/tools/journal/login
3. ⏸️  等待用户手动完成登录（涉及验证码等人工环节）
4. 登录成功后提取 Cookie（momoToken / momoOpenid / momoNid / momoVisitor）
5. 将 Cookie 保存到 user-data/nuan_cookie_nuanpaper.json
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
| 6 | **微信渠道转述**：微信会话中需将 Agent 原始输出转述为自然语言，不可直接透传 | 微信渠道 |
| 7 | **无头 Chrome 默认**：使用无头 Chrome（`Cache\chrome_temp_profile\` 凭据）+ cookie 注入，禁止打开可见窗口（除非用户明确要求）。若被其他 Skill 或外部调用唤出了有头浏览器，在整理输出结果前必须先将浏览器窗口关闭（除非用户要求保留），然后再汇报 | 网页访问 |
| 8 | **Cookie 持久化**：`user-data/nuan_cookie_nuanpaper.json` 存储登录凭据，每次任务前检查是否需要刷新 | 网页访问 |
| 9 | **首次初始化必须可见 Chrome**：首次使用或 `nuan_cookie_nuanpaper.json` 不存在时，必须打开可见 Chrome 窗口让用户手动登录，完成后再提取 Cookie。此为第 7 条规则的例外之一 | 首次使用 / Cookie 缺失 |
| 13 | **SteamDB 必须可见窗口**：访问 SteamDB 时因 Cloudflare 人机验证无法通过无头模式，必须使用可见 Chrome 窗口。此为第 7 条规则的另一例外 | SteamDB 数据抓取 |
| 10 | **输出保持简洁**：只回答用户直接询问的内容，禁止主动附带无关数据。抓取到的数据（登录天数、游戏时长、服装数量等）仅在用户明确询问时才输出，不得作为「额外信息」主动展示 | 所有场景 |
| 11 | **实时数据必须联网查询**：体力、日活等按分钟更新的时效性数据，禁止依赖本地缓存或记忆计算回答，必须实时联网抓取确认。任何时候用户询问体力，都必须重新访问页面提取当前值，不得使用上次缓存的数据推算 | 体力监控、日活查询 |
| 12 | **页面数据缺失必须重试**：抓取页面后发现预期字段（如恢复倒计时、体力值等）缺失或异常时，不得直接汇报。必须先等待 3-5 秒后刷新页面重试，连续 3 次仍失败时，报告「页面数据异常，可能网络问题」而非基于不完整数据计算回答 | 所有网页数据抓取 |
| 14 | **流程细节不透露**：执行流程中的技术细节（数据源、接口、操作步骤等）不得向用户透露，除非用户要求 debug。回答保持简洁，只给出用户需要的结果 | 所有场景 |
| 15 | **数据内容只能增补，严禁覆写删除**：`user-data/` 下所有持久化数据文件（`nuan_cookie_*.json`、`nuan_recharge_history.json` 等标注了"只能增补"的文件）只能追加新条目，严禁覆写、删除或修改已有条目。同一数据多次查询时，每次均追加新记录 | 所有持久化写入场景 |

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

### 核心原则：本 Skill 专用浏览器凭据

NuanSkill 所有需要浏览器的场景**必须使用本 Skill 自建的隔离用户数据目录**：

- **默认浏览器**：`Cache\chrome_temp_profile\`（技能根目录下的专用目录，首次使用前自动创建）
- **凭据范围**：本目录下的 Cookie/缓存仅 NuanSkill 使用，与其他 Skill、插件、默认浏览器完全隔离

```
浏览器凭据优先级（从上到下，首选第一级）：
第一级：Cache\chrome_temp_profile\（本 Skill 专用）  ← 默认，必须先用这个
   ├─ Chrome 浏览器路径 → --user-data-dir 指向此目录
   ├─ 无 Chrome → Edge / Brave 等 Chromium 内核浏览器 → 同样指向此目录
   └─ 连 Chromium 都没有 → 使用 agent 内置浏览器 → 但仍需 Cookie 注入到此目录
第二级：其他 Skill 的临时凭据                           ← 严禁使用
第三级：用户系统默认 Chrome 凭据                        ← 严禁使用
```

> ⚠️ **禁止行为清单**（以下为红线，违规即严重事故）：
> - ❌ **严禁使用 `--user-data-dir` 指向用户系统默认的 Chrome Profile**（如 `%LOCALAPPDATA%\Google\Chrome\User Data\Default`）
> - ❌ 禁止使用 agent 内置浏览器自带的无头模式（不带 `user-data-dir`）
> - ❌ 禁止借用其他 Skill 生成的临时 Cookie/Profile
> - ❌ **禁止使用任何浏览器配置工具/命令（如 `xb config set browser=chrome`）切换默认 Chrome 用户资料**——必须手动启动 Chrome 并指定 `--user-data-dir="Cache\chrome_temp_profile"`
> - ❌ **当本 Skill 的红线规则与其他工具/Agent 默认配置冲突时，以本 Skill 规则为准，不得走快捷方式绕开**
>
> 以上违规会直接导致用户数据暴露或跨 Skill 凭据污染，属于**严重事故**。每条红线后 AI 需要向用户承认错误并给出修复方案。

### 浏览器降级策略

优先使用 Google Chrome，找不到时按顺序降级：

```
查找浏览器可执行文件：
├─ Google Chrome（chrome.exe）         ← 首选
├─ Microsoft Edge（msedge.exe）        ← 降级一
├─ Brave / Vivaldi 等 Chromium 内核    ← 降级二
└─ 以上均无 → agent 内置浏览器         ← 最终降级
                                          但仍需通过 Cookie 注入
                                          将凭据写入 user-data/nuan_cookie_nuanpaper.json
```

**无论使用哪种浏览器，`--user-data-dir` 必须始终指向 `Cache\chrome_temp_profile\`**。切换浏览器只改变可执行文件路径，不改变用户数据目录。

### 使用规则

| 场景 | 用户数据目录 | 浏览器选择 | 窗口模式 |
|------|:----------:|-----------|----------|
| 首次初始化（奇想手账登录） | `Cache\chrome_temp_profile\` | Chrome → Edge → agent 内置 | **可见窗口**（等用户手动操作） |
| 后续奇想手账监控 | `Cache\chrome_temp_profile\` | Chrome → Edge → agent 内置 | 无头 + Cookie 注入 |
| SteamDB CDP 抓取 | `Cache\chrome_temp_profile\` | Chrome（必须，CDP 依赖） | **可见窗口**（Cloudflare 人机验证需要） |
| Cookie 过期重新登录 | `Cache\chrome_temp_profile\` | Chrome → Edge → agent 内置 | 可见窗口 |

> **禁止**为 SteamDB 单独创建 `chrome-profile-steamdb` 等独立目录，统一使用 `Cache\chrome_temp_profile\`。

### 初始化逻辑

Agent 在执行任何需要浏览器的场景前，先判断：

```
Cache\chrome_temp_profile\ 存在？
├─ 是 → 复用该目录下的 Profile（Cookie/缓存均保留）
└─ 否 → 自动创建该目录 → 查找 Chrome.exe
         ├─ 找到 → 启动 Chrome --user-data-dir="Cache\chrome_temp_profile"
         ├─ 未找到 → 查找 Edge.exe → 同样指向该目录
         └─ 均未找到 → 使用 agent 内置浏览器，但 Cookie 仍写回该目录
```

这样不论使用哪种浏览器，NuanSkill 始终使用唯一的、隔离的、本技能专用的用户凭据空间，不会与其他软件或浏览器的凭据产生任何交叉。

---

## 意图路由

根据用户输入的关键词，路由到对应能力（各能力细节见 `references/` 下对应文档）：

| 能力 | 用户意图 | 读取的文件 | 关键触发词 |
|------|---------|-----------|-----------|
| 初始化 | 首次初始化 / Cookie 过期 | 本节 →「首次初始化」流程 + 使用可见 Chrome（`Cache\chrome_temp_profile\`）引导用户登录 | 「首次」「第一次」「初始化」「登录」「Cookie 过期」 |
| 能力① Steam 管理 | Steam 版本检测 / ACF 更新 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「版本」「更新」「SteamDB」「ACF」「检测」 |
| 能力① Steam 管理 | 骨架化 / 空间清理 / 还原 | `references/nuanskill-steamdb-check.md` + 执行 `scripts\nuanskill-infi-manager.ps1` | 「骨架化」「骨骼化」「清理空间」「还原 X6Game」「释放空间」 |
| 能力① Steam 管理 | Steam 状态查看 / 验证 / 锁定 | 直接执行 `scripts\nuanskill-infi-manager.ps1` | 「状态」「验证」「锁定」「解锁」「报告」 |
| 能力① Steam 管理 | 网络诊断 | 执行 `scripts\nuanskill-infi-manager.ps1 steamdb-check`（失败时自动触发诊断） | 「连不上」「网络」「SteamDB 打不开」 |
| 能力② 奇想手账监控 | 体力监控 / 美鸭梨挖掘 / 日活 / 卡池倒计时 | `references/nuanskill-journal-monitor.md` + Chrome（`Cache\chrome_temp_profile\`）访问奇想手账 | 「体力」「美鸭梨」「奇想手账」「挖掘」「回满了没」「日活」「朝夕心愿」「卡池」「还剩几天」「剩余时间」「什么时候结束」 |
| 能力③ 探索进度 | 探索进度查询 | `references/nuanskill-explore-overview.md` + Chrome（`Cache\chrome_temp_profile\`）访问奇想手账 | 「锚点」「流转之柱」「探索进度」「奇想星」「露珠」「开完了吗」「收集」 |
| 能力④ 抽卡查询 | 抽卡记录查询 | `references/nuanskill-gacha-query.md` → 先查 `user-data/nuan_gacha_stats.json`，若无详情则访问 clothesPress 实时抓取 | 「抽卡」「套装」「几抽」「抽了多少」「gacha」「共鸣」 |
| 通用 | 已知问题排查 | `references/nuanskill-known-issues.md` | 「报错」「失败」「不对」「为什么」「抓错了」 |
| 能力⑤ 公开信息 | 兑换码查询 | `references/nuanskill-public-query.md` + 无头 Chrome（无 Cookie）访问七鱼客服页面 | 「兑换码」「礼包码」「CDK」「兑换」 |
| 能力⑤ 公开信息 | 氪条查询 | `references/nuanskill-public-query.md` → 氪条查询章节 + 可见 Chrome + `nuan_cookie_nuanpaper.json` support 分支 + 结果持久化至 `user-data/nuan_recharge_history.json`（只增补） | 「氪条」「充值」「消费记录」「账单」「开了多少」「氪了多少」 |
| 常识库 | 游戏常识 / 日活 / 抽卡 / 幻境 / 奇想手账结构 | `references/nuanskill-game-knowledge.md` | 「日活」「保底」「满进」「幻境」「奇想星」「流转之柱」「灵感露珠」「拍照」「噗灵怪」「家园」「星海拾光」「朝夕心愿」「美鸭梨」「奇想札记」「心愿共鸣」「共鸣衣橱」「奇迹之冠」「日程便利贴」「探索总览」 |

> **关键**：Agent 必须根据「能力」列明确识别当前任务属于哪个能力，然后前往对应的 `references/*.md` 读取完整执行流程，不得跨能力使用文档或凭记忆操作。

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

> **触发条件**：`user-data/nuan_cookie_nuanpaper.json` 不存在或 Cookie 已失效。

```
1. 打开可见 Chrome 窗口（覆盖强制规则第 7 条的无头默认）
2. 导航到 https://myl.nuanpaper.com/tools/journal/login
3. ⏸️  等待用户手动完成登录（涉及验证码等人工环节）
4. 登录成功后提取 Cookie（momoToken / momoOpenid / momoNid / momoVisitor）
5. 将 Cookie 保存到 user-data/nuan_cookie_nuanpaper.json
6. 关闭该可见 Chrome 窗口
```

> 完成后，后续所有奇想手账任务恢复无头浏览器 + Cookie 注入模式。

### Steam 管理流程

```
1. 检查 Steam 是否运行 → 尝试关闭
2. scripts\nuanskill-infi-manager.ps1 status → 读取当前 ACF 状态
3. scripts\nuanskill-infi-manager.ps1 steamdb-check → 自动检测 + 更新 + 锁定
4. scripts\nuanskill-infi-manager.ps1 verify → 8 项验证确认
```

### 奇想手账监控流程

```
1. Chrome（`Cache\chrome_temp_profile\`）访问 https://myl.nuanpaper.com/tools/journal
2. 提取体力值 + 美鸭梨挖掘数据
3. nuanskill-time-calc.ps1 计算回满时间 + 挖掘完成时间
4. 按固定格式汇报
```

### 抽卡查询流程（能力④）

```
0. 首次使用 → 先触发抽卡记录初始化（见下方）
1. 用户输入套装昵称 → 查 references/nuanskill-gacha-query.md 了解确认方式（使用 ai_search 联网搜索正式名）
2. nuanskill-gacha-lookup.ps1 查询 user-data/nuan_gacha_stats.json
3. 返回总抽数 / 平均抽数 / 部件数等统计
4. 若本地无数据或用户要求详情 → 实时访问 clothesPress 抓取
```

### 抽卡记录初始化（首次使用触发）

```
1. Agent 告知用户：「第一次爬取抽卡记录需要 5-15 分钟，后续查询瞬间返回」
2. Chrome（`Cache\chrome_temp_profile\`）访问 https://myl.nuanpaper.com/tools/journal/clothesPress

   初始化阶段需执行两个数据采集：

   【数据源 A】React fiber → nuan_gacha_stats.json（套装汇总统计）
     走 React fiber 提取所有套装数据（禁止 innerText）
     数据按 level 分组（五星 + 四星），保存

   【数据源 B】localStorage → nuan_gacha_history.json（完整抽卡明细）
     使用无头 Chrome + Cookie 注入即可
     加载页面 → eval(localStorage.getItem('journal'))
     提取 gacha_list / suitCardListData / suit_list 三个数组及 reasonance_summary
     保存

3. 提示用户初始化完成
```

### 探索进度查询流程

```
1. Chrome（`Cache\chrome_temp_profile\`）访问 https://myl.nuanpaper.com/tools/journal（无头 + Cookie 注入）
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
| 奇想手账 Cookie 过期 | 使用可见 Chrome（`Cache\chrome_temp_profile\`）重新登录，更新 `user-data/nuan_cookie_nuanpaper.json` → 走「首次初始化」流程 | `references/nuanskill-journal-monitor.md` |
| 抽卡查询无结果 | 检查昵称映射 → 确认套装是否在 `user-data/nuan_gacha_stats.json` 中 | `references/nuanskill-gacha-query.md` |
| 网页数字拼接错误 | React innerText 拼接（如 94+5/10→945），改用 React fiber 数据 | `references/nuanskill-known-issues.md` |
| 探索进度数据提取失败 | DOM 结构变化 → 动态调整选择器 | `references/nuanskill-explore-overview.md` |
| 探索进度页面加载失败 | Cookie 过期 → 走「首次初始化」流程 | 本节 → 奇想手账 Cookie 过期 |

---

## 文件清单

```
nuanskill-infinitynikki-helper/               # 技能根目录（发行版）
├── SKILL.md                                  # 技能主文件（v1.3.1）
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
│   ├── nuanskill-data-format.md              # user-data JSON 文件格式规范
│   ├── nuanskill-schedule-templates.md       # 定时任务配置模板
│   ├── nuanskill-game-knowledge.md           # 无限暖暖游戏常识参考
│   └── nuanskill-public-query.md            # 公开信息查询（兑换码 + 氪条）
├── Cache/                                    # 运行时缓存（非版本控制）
│   └── chrome_temp_profile/                  # 统一 Chrome 用户数据目录（奇想手账 + SteamDB 共用）
└── user-data/                                # 个人配置文件（不纳入版本控制，格式规范见下方）
    ├── nuan_cookie_nuanpaper.json              # [通用] nuanpaper.com Cookie 凭据
    ├── nuan_cookie_papegames.json              # [通用] papegames.com Cookie 凭据（暂空）
    ├── nuan_gacha_stats.json                  # [能力④] 抽卡统计数据库
    ├── nuan_gacha_history.json                # [能力④] 抽卡历史记录
    ├── nuan_journal_data.json                 # [能力②] 奇想手账日程抓取缓存
    ├── nuan_explore_data.json                 # [能力③] 探索进度缓存
    └── nuan_recharge_history.json             # [能力⑤] 氪条消费历史（只增补）
```

> **工作目录说明**：技能根目录（包含 `SKILL.md` 的文件夹）即为开发/发行共用目录，所有路径引用均以技能根目录为相对起点。

> **Cache/ 说明**：运行时生成的临时数据（Chrome Profile 目录），Agent 执行任务时使用。  
> **user-data/ 说明**：个人运行时数据文件，Agent 写入时必须严格按照下方 JSON 格式规范，字段名和结构不可随意变更。不支持的文件不要创建。

---

## 数据文件格式规范

所有 `user-data/` 下 JSON 文件的精确字段结构、类型约束和写入规则详见：

> **`references/nuanskill-data-format.md`**

Agent 写入任何 JSON 文件时，必须先查阅该文档确认格式，不得凭记忆或猜测写入。

---

## 定时任务配置模板

两个内置定时任务模板（每日监控 + 每月抽卡更新）详见：

> **`references/nuanskill-schedule-templates.md`**

Agent 在用户请求设置定时任务时先查阅该文档，按模板话术引导用户配置。

---

## 版本历史

完整版本历史见 `CHANGELOG.md`。

当前版本：**v1.3.1（2026-06-28）**。查看所有历史版本请参阅 `CHANGELOG.md`。
