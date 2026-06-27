# 奇想手账抽卡查询 — Agent 执行参考

> **能力编号**：能力④
> **网页来源**：https://myl.nuanpaper.com/tools/journal/clothesPress
> **本地数据库**：`user-data/nuan_gacha_stats.json`（主数据源，React fiber 直接爬取）
> **辅助参考**：`user-data/nuan_gacha_history.json`（原始导出，三星已过滤）

---

## 用户提问 → 能力映射

| 用户问 | 应执行动作 |
|--------|-----------|
| 「某套池子抽了多少抽」 | 直接查 `nuan_gacha_stats.json`（汇总统计数据已足够） |
| 「某套池子抽了多少齐的」 | 直接查 `nuan_gacha_stats.json`（看 `total_resonance`） |
| 「最后一件出的什么」「详情」 | 查 `nuan_gacha_history.json`（含每抽记录），或从 localStorage 提取完整历史 |
| 「没有收录的新套装」 | 访问 clothesPress 实时抓取 |
| 「当期卡池什么时候结束」 | 查 `user-data/nuan_journal_data.json` → `tabs.日程便利贴.current_banner_pool.ends_at`（每日监控自动更新） |
| 「初始化抽卡历史数据库」 | 走 localStorage 提取完整历史（含逐条抽卡记录） |

---

## 查询流程

```
用户输入昵称 → ai_search 确认正式名 → nuan_gacha_stats.json 匹配 → 格式化输出
              ↓ 未命中 → 实时访问 clothesPress 抓取并更新本地
```

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1. 接收昵称 | 如「花套」「鸟套」「鱼套」 | 社区约定俗称的简称 |
| 2. 联网确认 | 搜索「无限暖暖 + 昵称 + 套装」，搜到杂鱼结果不要停，按以下方法深挖：① 换「昵称 + 五星」「昵称 + 套装」等方向再搜；② 拿猜测的正式名反向搜索「正式名 + 昵称」交叉验证；③ 优先采信高权威来源（官网文章、正规游戏媒体），不要凭视觉印象做直觉判断；④ 多词条交叉验证后再确认，如「小红帽」同时搜「小红帽 无限暖暖」「她是不驯火 小红帽」锁定映射 | 确认正式名称，避免歧义 |
| 3. 数据匹配 | 先查 `nuan_gacha_stats.json` 中按 `suit_name` 精确匹配 | 五星/四星各自独立数组 |
| 4. 输出 | 返回统计信息 | 套装名、星级、平均共鸣、总计共鸣 |

> ⚠️ **关键**：当用户问抽卡问题时，必须优先走能力④流程，首先查阅 `references/nuanskill-gacha-query.md`，不得使用其他能力的文档或凭记忆回答。

---

## 输出字段

| 字段 | 来源 | 说明 |
|------|------|------|
| 套装名 | `suit_name` | 正式名称 |
| 星级 | `rarity` | 5 或 4 |
| 平均共鸣次数 | `avg_resonance` | 单件平均抽数 |
| 总计共鸣次数 | `total_resonance` | 全套装总抽数 |

---

## 数据采集流程（React fiber）

### 访问链接

直接跳转 https://myl.nuanpaper.com/tools/journal/clothesPress，无需从首页模拟点击导航。该页面是奇想手账的独立子页面，URL 直达。

### React fiber 提取方法

**严禁使用 innerText/DOM 文本**，必须走 React fiber 获取原始数据：

```
1. Chrome（`Cache\chrome_temp_profile\`） 访问 https://myl.nuanpaper.com/tools/journal/clothesPress
2. 等待页面渲染完成（.cardWrpaper 元素出现）
3. 遍历所有 .cardWrpaper 元素
4. 读取 element.__reactFiber 进入 fiber 树
5. 从 suitItem 摘出五个字段：
```

| React 字段 | 含义 | JSON 字段 |
|------------|------|-----------|
| `suitItem.name` | 套装名称 | `suit_name` |
| `suitItem.level` | 星级（5/4） | `rarity` |
| `suitItem.totalDrawNum` | 总计共鸣次数（整数） | `total_resonance` |
| `suitItem.averageDrawNum` | 平均共鸣次数（浮点） | `avg_resonance` |
| `suitItem.partsCount` | 套装总部件数 | `parts_count` |

统计：五星 31 个 + 四星 69 个 = 100 个套装。

### 数据序列化

按 `level` 分两组（五星 + 四星），序列化为 JSON，保存到 `user-data/nuan_gacha_stats.json`。

> **写入格式**：必须严格按照 `SKILL.md` →「数据文件格式规范」→ `nuan_gacha_stats.json` 的字段结构写入，`rarity` 为数字（5/4）不可写成字符串。

---

## 数据采集流程（localStorage — 完整抽卡历史）

**适用场景**：获取用户所有历史抽卡记录的逐条明细（含每抽结果、保底计数、卡池映射），用于回答「最后一件出的是什么」「某件衣服在第几抽出的」等需要部件明细的问题。

### 数据源

clothesPress 页面加载后，Redux 持久化状态存储在 `localStorage` 的 `journal` 键中，base64 编码。

```
localStorage.getItem('journal')
  → Base64 解码（atob）
    → state.userSelfData.gacha_list      → 抽卡记录明细
    → state.suitCardListData             → 卡池/套装明细
    → state.userSelfData.suit_list       → 套装 ID 列表
```

### 提取流程

```
1. Chrome（无头 + Cookie 注入）访问 https://myl.nuanpaper.com/tools/journal/clothesPress
2. 注入 Cookie 保持登录态：momoToken / momoOpenid / momoNid / momoVisitor
3. 等待页面完全加载（React 渲染完成）
4. eval 执行：
   const raw = localStorage.getItem('journal');
   const data = JSON.parse(atob(raw));
5. 从 data 中提取以下内容（缺一不可）：
```

| 提取目标 | 数据路径 | 必须包含的字段 |
|----------|---------|---------------|
| 抽卡记录 | `state.userSelfData.gacha_list` | `card_pool_id`, `pool_cnt`, `result`, `rarity`, **`times_from_last_five_stars`**（保底计数） |
| 卡池明细 | `state.suitCardListData` | `card_pool_id`, `name`, `totalDrawNum`, `averageDrawNum`, **`firstSuit`**（含 `cloth_id`/`display_type`/`pool_cnt`）, **`secondSuit`**, `evolutions1/2/3` |
| 汇总统计 | `state.userSelfData` | **`reasonance_summary`**（全部子项）, `suit_list` |
| 元数据 | （从以上推算） | `total_draws`, `periodic_draws`, `permanent_draws`, `gacha_records_count`（=gacha_list.length） |

```
6. 重组数据后序列化为 JSON 写入 user-data/nuan_gacha_history.json
```

> ⚠️ **关键**：`pool_summary` 中每个卡池的 `firstSuit`/`secondSuit` 数组包含逐部件的 `cloth_id` 和 `pool_cnt`，这是回答「某件衣服在第几抽出的」的精确依据。提取时**必须完整保留**这两个数组，不要只取外层元信息而丢掉部件明细。
>
> ⚠️ `_metadata` 中的 `user_uid`、`user_nickname`、`user_level` 等字段从 Redux 状态中提取，一并写入以丰富数据上下文。

### 已知限制

| # | 限制 | 说明 |
|---|------|------|
| 1 | **无头模式可用** | 实测无头 Chrome 可正常读取 localStorage，与可见窗口数据完全一致，无需弹窗 |
| 2 | **不需要 API 调用** | 数据在页面加载时由 Redux 从 localStorage 恢复，不发网络请求 |
| 3 | **suitCardListData 编码问题** | 部分中文字段存在 UTF-8 / Latin-1 双重编码损坏，但结构 ID 和数值字段完整可用 |
| 4 | **全量数据** | 包含完整抽卡记录，无需从 stats 或 history 旧文件推算 |

---

## 满进判断（进化状态分析）

### 数据来源

从 `suitCardListData`（localStorage 提取）的每个卡池条目中获取：

| 字段 | 说明 |
|------|------|
| `firstSuit` | 第一套部件列表（9~11 件），每件含 `cloth_id`、`display_type`、`pool_cnt`、**`drawNum`** |
| `secondSuit` | 第二套部件列表（结构同 firstSuit），**`drawNum > 0` 表示已抽到** |
| `evolutions1/2/3` | 进化档位预设信息（**非达成状态**，不可用于判断） |

### 判断规则

**满进** = `firstSuit` 全部 `drawNum > 0` **且** `secondSuit` 全部 `drawNum > 0`

即第二套每个部件都已实际抽出才算满进。

```
for each 卡池 (level=5):
    fs_got = count(firstSuit, where drawNum > 0)
    ss_got = count(secondSuit, where drawNum > 0)
    满进 ⇔ fs_got == len(firstSuit) AND ss_got == len(secondSuit)
```

**常驻五星参考值**：满进需要 18 件（firstSuit 9 + secondSuit 9），晶莹诗集需要 20 件（10+10）。

**限定五星参考值**：限定五星一般 10 件（5+5）到 22 件（11+11）不等，具体以 `firstSuit.length + secondSuit.length` 为准。

### 关键踩坑

| # | 错误做法 | 正确做法 |
|---|---------|---------|
| 1 | 用 `evolution_suit_id` 非空判断满进 | 用 `secondSuit.drawNum > 0` 判断 |
| 2 | `evolutions` 字段存在即视为已达成 | `evolutions` 只是预设元数据，对所有玩家相同，不代表已获得 |
| 3 | 用 `parts_count`（总部件数）推断已收集数 | `parts_count` 是套装总部件数，非已收集数 |

### 无法判断的内容

| # | 限制 | 说明 |
|---|------|------|
| 1 | 三星记录不可见 | `gacha_list` 不含三星，`suitCardListData` 也无三星卡池 |
| 2 | `evolutions` 无达成标记 | `evolutions1/2/3` 只有 `image`、`evolution_suit_id`、`evolution_suit_name` 三个预设字段，没有 bool 表示是否已达成 |
| 3 | 中文字段编码损坏 | `suitCardListData` 的中文字段存在 Latin-1/UTF-8 双重编码问题 |
| 4 | 常驻池 `gacha_list` 中 `rarity` 为 0 | 常驻池按 `card_pool_id=1` 归类，无法按星级筛选 |

---

## 数据文件

### nuan_gacha_stats.json（主数据源）

React fiber 直爬的套装抽卡统计。日常查询优先使用此文件。

**初始化时机**：用户第一次使用抽卡能力时，Agent 应主动触发初始化：

```
1. 告知用户「第一次爬取抽卡记录需要 5-15 分钟，爬取完成后后续查询瞬间返回」
2. 访问 clothesPress 走 React fiber 流程
3. 保存到 user-data/nuan_gacha_stats.json
4. 提示用户初始化完成
```

### nuan_gacha_history.json（辅助参考）

原始抽卡导出，`pool_cnt` 为 0-based。`total_pulls` 字段不可靠，三星记录已被奇想手账过滤。

> **写入格式**：写入此文件时必须严格按照 `SKILL.md` →「数据文件格式规范」→ `nuan_gacha_history.json` 的字段结构，不得自行增删 key 或改变嵌套层级。

`pool_cnt` 规律：`max(pool_cnt) + 1 = 网页总计共鸣次数`，对新套装成立。老套装有个别历史离群值。

---

## 已知踩坑（详见 `references/nuanskill-known-issues.md`）

| # | 问题 | 严重性 | 修复方案 |
|---|------|--------|---------|
| 1 | `innerText` 数字拼接（19→191，94→945） | **严重** | 绕开 DOM 文本，走 React fiber |
| 2 | 星级分类错误（予梦心时被误判四星） | **严重** | 走 `suitItem.level`，与页面 tab 对齐 |
| 3 | 三星垫抽完全不可见 | 无解 | 所有数据源均无法获取 |
| 4 | `parts_count` 是套装理论总部件数（固定值），非用户已收集数 | **严重** | 不可用于判断用户收集进度，仅代表该套装一共有多少件（如 9/10/11），不随玩家个性化 |
| 5 | 数据为静态快照，不会自动更新 | 注意 | 需定期重新跑一次 fiber 抓取 |

> **一句话总结**：别碰 innerText、别信 DOM 文本，直接从 React fiber 偷数据。
