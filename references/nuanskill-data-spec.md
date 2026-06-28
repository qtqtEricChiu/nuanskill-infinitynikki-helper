# NuanSkill 数据文件规范

> **能力编号**：通用（所有能力的用户数据持久化遵循此方案）
>
> **核心原则**：用户数据与 Skill 代码分离，所有运行时产生的用户数据统一存放在 Agent 平台提供的用户数据目录中，Skill 内不硬编码任何平台路径或个人标识。
>
> Agent 写入 `{USER_DATA_DIR}` 下所有 JSON 文件时**必须严格遵循以下格式**，不得增删字段、改变字段名或嵌套层级。

---

## 一、目录约定

```
<AGENT_USERDATA_DIR>\                         # Agent 平台提供的用户数据根目录
└── nuanskill-infinitynikki-helper\           # Skill 专属子目录
    ├── nuan_profile.json                     # 用户凭据（多子域名分组）
    ├── nuan_gacha_stats.json                 # 抽卡聚合统计
    ├── nuan_gacha_history.json               # 抽卡历史明细
    ├── nuan_journal.json                     # 奇想手账页面快照
    ├── nuan_explore.json                     # 探索进度缓存
    ├── nuan_recharge_history.json            # 氪条消费历史（只增补）
    └── chrome-profile\                       # Chrome 持久化 Profile（含 Cookie / localStorage）
        └── ...
```

### 路径变量定义

Skill 内声明一个统一变量 `USER_DATA_DIR`，所有脚本统一引用该变量，不得硬编码具体路径：

```
USER_DATA_DIR = <AGENT_USERDATA_DIR>\nuanskill-infinitynikki-helper\
PROFILE_PATH    = {USER_DATA_DIR}nuan_profile.json
GACHA_STATS     = {USER_DATA_DIR}nuan_gacha_stats.json
GACHA_HISTORY   = {USER_DATA_DIR}nuan_gacha_history.json
JOURNAL_DATA    = {USER_DATA_DIR}nuan_journal.json
EXPLORE_DATA    = {USER_DATA_DIR}nuan_explore.json
RECHARGE_HIST   = {USER_DATA_DIR}nuan_recharge_history.json
CHROME_PROFILE  = {USER_DATA_DIR}chrome-profile\
```

> **`<AGENT_USERDATA_DIR>` 解析规则**：Agent 必须按以下优先级确定该路径，不得留空或凭记忆猜测：
>
> 1. **环境变量**：若 Agent 定义了 `$env:AGENT_USERDATA_DIR` 环境变量，直接使用
> 2. **平台已知路径**：按当前 Agent 平台查下表
>
> | Agent 平台 | `<AGENT_USERDATA_DIR>` 实际路径 |
> |-----------|-------------------------------|
> | **Marvis** | `%APPDATA%\Tencent\Marvis\User\<uid>\user-data\` |
> | **QClaw** | `<QClaw安装目录>\user-data\` |
> | **OpenClaw** | 由运行时 `$AGENT_USERDATA_DIR` 决定（默认 `<ClawData>\user-data\`） |
> | **WorkBuddy** | 由 WorkBuddy 配置中 `user_data_dir` 字段决定 |
> | **Claw（原版）** | `%APPDATA%\Claw\User\<uid>\user-data\`（Win）/ `~/Library/Application Support/Claw/User/<uid>/user-data/`（macOS） |
> | **Chatwise** | `~/Library/Application Support/Chatwise/user-data/`（macOS） |
> | **MindMac** | `~/Library/Application Support/MindMac/user-data/`（macOS） |
> | **Cerebro** | `<CerebroData>\user-data\`（由 `$CEREBRO_USERDATA_DIR` 覆盖） |
> | **其他** | 优先检查 `$env:AGENT_USERDATA_DIR`，未设置时使用 `<Skill根目录>\user-data\`（回退方案） |
>
> 3. **回退方案**：以上均无法确定时，使用 `<Skill根目录>\user-data\` 作为 `{USER_DATA_DIR}`，确保 Skill 可独立运行
>
> > `<uid>` 为各平台分配给当前登录用户的唯一标识符，Skill 内不引用具体值。
> > Skill 层使用变量名，不关心实际路径解析结果。
> > 新增 Agent 平台时，遵循`环境变量 → 平台已知路径 → 回退`的优先级，在文档中追加对应行即可。

---

## 二、各文件结构定义

### nuan_profile.json（[通用] 用户凭据）

以完整子域名为一级 key，每个子域名下以时间戳命名条目（`current_YY-MM-DD` / `previous_YY-MM-DD`）。**只能增补，严禁覆写或删除已有条目**。

> **回退策略**：若 `myl.nuanpaper.com` 的 token 失效，Agent 可尝试使用 `support-infinitynikki.nuanpaper.com` 的 `momoToken`/`momoOpenid` 登录（二者 key 相同），但注意 `support` 分支含额外字段（`aliyungf_tc_*`），仍应分开存储。

```json
{
  "_note": "cookies只能增补，严禁覆写删除",
  "_last_updated": "ISO时间字符串",
  "myl.nuanpaper.com": {
    "_note": "奇想手账 - 日程便利贴 / 抽卡查询 / 探索总览",
    "current_YY-MM-DD": {
      "cookies": {
        "momoToken": "字符串",
        "momoOpenid": "字符串",
        "momoNid": "字符串",
        "momoVisitor": "字符串"
      }
    },
    "previous_YY-MM-DD": {
      "cookies": {
        "momoToken": "字符串",
        "momoOpenid": "字符串",
        "momoNid": "字符串",
        "momoVisitor": "字符串"
      }
    }
  },
  "support-infinitynikki.nuanpaper.com": {
    "_note": "客服中心 - 自助发票页（能力⑤氪条查询）",
    "current_YY-MM-DD": {
      "cookies": {
        "momoToken": "字符串",
        "momoOpenid": "字符串",
        "momoNid": "字符串",
        "momoVisitor": "字符串",
        "aliyungf_tc_myl": "字符串（可选）",
        "aliyungf_tc_support": "字符串（可选）"
      }
    }
  },
  "papegames.com": {
    "_note": "papegames 跨域凭据（infinitynikki-pay 等）",
    "current_YY-MM-DD": {
      "cookies": {}
    }
  }
}
```

> **规则**：
> - 命名规则：`current_` / `previous_` + 日期（YY-MM-DD）。若同一日期有多条，追加 `_1`、`_2` 后缀
> - `previous_YY-MM-DD` 为可选，仅在需要保留旧 Cookie 回退时写入
> - 新增子域名时直接追加到根对象，不破坏已有结构（仍遵守只增补原则）
> - `_note` 为可读注释，Agent 不依赖其内容做逻辑判断

---

### nuan_gacha_stats.json（[能力④] 抽卡统计）

**写入规则**：每次爬取时覆盖更新（最新快照）。

```json
{
  "five_star_suits": [
    {
      "suit_name": "套装名称（字符串）",
      "rarity": 5,
      "parts_count": "总部件数（数字）",
      "total_resonance": "总计共鸣次数（数字）",
      "avg_resonance": "平均共鸣次数（数字）"
    }
  ],
  "four_star_suits": [
    {
      "suit_name": "套装名称（字符串）",
      "rarity": 4,
      "parts_count": "总部件数（数字）",
      "total_resonance": "总计共鸣次数（数字）",
      "avg_resonance": "平均共鸣次数（数字）"
    }
  ]
}
```

> `rarity` 严格为数字 `5` 或 `4`，不可用字符串。数据来源：React fiber 直爬。

---

### nuan_gacha_history.json（[能力④] 抽卡历史）

**写入规则**：每次爬取时覆盖更新（最新快照）。

```json
{
  "_metadata": {
    "generated_at": "2026-06-27T13:00:00（ISO 时间字符串）",
    "source_page": "数据来源页面的 URL（字符串）",
    "user_uid": "用户 UID（数字）",
    "user_nickname": "用户昵称（字符串）",
    "user_level": "用户等级（数字）",
    "total_draws": "总计抽数（数字）",
    "periodic_draws": "限定抽数（数字）",
    "permanent_draws": "常驻抽数（数字）",
    "total_clothes_owned": "总计拥有服装数（数字）",
    "total_suits_owned": "总计拥有套装数（数字）",
    "gacha_records_count": "抽取记录条数（数字）"
  },
  "reasonance_summary": {
    "total": "共鸣总数（数字）",
    "periodicFiveStarCard": { "totalOwnedClothesNum": 数字, "averageDrawNum": 数字, "cardName": "字符串" },
    "periodicFourStarCard": { ... },
    "permanentFiveStartCard": { ... },
    "permanentFourStarCard": { ... }
  },
  "gacha_list": [
    {
      "card_pool_id": "卡池 ID（数字/字符串）",
      "pool_cnt": "该卡池内的抽卡序号 0-based（数字）",
      "result": "抽出内容 ID（字符串）",
      "rarity": "星级（数字，5 或 4）",
      "times_from_last_five_stars": "距离上次五星的抽数（数字，保底计数）"
    }
  ],
  "pool_summary": [
    {
      "card_pool_id": "卡池 ID",
      "card_name": "卡池名称（字符串）",
      "totalDrawNum": "总抽数（数字）",
      "averageDrawNum": "平均抽数（数字）",
      "firstSuit": [
        {
          "cloth_id": "部件 ID",
          "display_type": "部件类型（字符串）",
          "pool_cnt": "部件序号 0-based（数字）"
        }
      ],
      "secondSuit": [ ... ],
      "evolutions1": "进化信息",
      "evolutions2": "进化信息",
      "evolutions3": "进化信息"
    }
  ]
}
```

> **关键**：`gacha_list` 中 `times_from_last_five_stars` 为保底计数，**必须保留**不可丢弃。`pool_summary` 的 `firstSuit`/`secondSuit` 数组包含逐部件的 `cloth_id` 和 `pool_cnt`，是回答「某件衣服在第几抽出的」的精确依据，**提取时必须完整保留**这两个数组。`_metadata` 丰富化字段（user_uid、periodic_draws 等）从 Redux 状态中提取一并写入。禁止写入 Cookie 等敏感信息。中文编码损坏时保持原始值不动。

---

### nuan_journal.json（[能力②] 奇想手账快照）

**写入规则**：每次抓取时覆盖更新（最新快照）。

```json
{
  "header": {
    "username": "用户昵称（字符串）",
    "stylist_id": "搭配师 ID（字符串/数字）",
    "login_days": "登录天数（数字）",
    "playtime_hours": "游戏时长小时（数字）",
    "clothing_count": "服装收集数（数字）",
    "cloak_count": "斗篷数（数字）",
    "blueprint_count": "设计图数（数字）"
  },
  "tabs": {
    "日程便利贴": {
      "active_energy": "当前体力值（数字/字符串如'197/350'）",
      "energy_recovery": "恢复倒计时（字符串如'02:15'）",
      "daily_wish": {"current": "当前积分（数字）", "total": "上限（数字）"},
      "meiyali_mining": {"current": "已完成数", "total": "总数", "items": []},
      "heart_breakthrough": {"status": "已挑战/未挑战", "boss": "当前 Boss 名称"},
      "current_banner_pool": {
        "remaining": "当期卡池剩余时间（字符串，如'19天12小时50分'）",
        "ends_at": "预计结束时间点（ISO 时间字符串，如'2026-07-17T03:30'）"
      }
    }
  }
}
```

> `tabs` 下的标签页 key 为页面实际中文名称，不可翻译或简写。`header` 中字段全为数字时用数字类型，不要写成字符串。

---

### nuan_explore.json（[能力③] 探索进度）

**写入规则**：每次查询时覆盖更新（最新快照）。

```json
{
  "updated_at": "2026-06-27T13:00:00（ISO 时间字符串）",
  "regions": {
    "区域名称（字符串）": {
      "流转之柱": { "current": 数字, "total": 数字 },
      "奇想星": { "current": 数字, "total": 数字 },
      "灵感露珠": { "current": 数字, "total": 数字 },
      "子区域": {
        "子区域名收集项名": [当前数（数字）, 总数（数字）]
      }
    }
  }
}
```

> `updated_at` 必须精确到分钟（`yyyy-MM-ddTHH:mm` 格式），`current` 和 `total` 全为数字类型。

---

### nuan_recharge_history.json（[能力⑤] 氪条消费历史）

按查询时间戳分组存储，每次查询结果作为一条历史记录追加。**只能增补，严禁覆写或删除已有条目**。

```json
{
  "note": "消费历史持久化存储，只能增补，严禁覆写删除",
  "records": [
    {
      "queried_at": "ISO 时间字符串",
      "query_range": "最近6个月（或用户指定范围如最近1个月/3个月）",
      "total_amount_yuan": "汇总金额（数字，单位元）",
      "order_count": "订单笔数（数字）",
      "orders": [
        {
          "order_id": "订单 ID（字符串）",
          "item_name": "道具名称（字符串）",
          "recharge_time": "充值时间（字符串，如'2026-03-03 01:31:55'）",
          "amount_yuan": "充值金额（数字，单位元）"
        }
      ]
    }
  ]
}
```

> **关键规则**：
> - 每次用户查询氪条时，将本次查询结果（含所有订单明细）**追加**到 `records` 数组末尾，**严禁覆写或删除已有记录**
> - `queried_at` 为本次查询发生的精确时间（ISO 格式）
> - `query_range` 记录查询的时间范围（如"最近6个月"），用于区分不同查询
> - 若同一时间范围重复查询（如用户多次查询同一区间），每次均追加新记录，不可覆盖旧记录
> - 若查询结果为空（无充值记录），仍需追加一条 `order_count: 0`、`orders: []` 的记录，不可跳过

---

### chrome-profile\ —— Chrome 持久化 Profile

启动 Chrome 时 `--user-data-dir` 指向此目录，Cookie 和 localStorage 由 Chromium 原生管理，无需单独导出 cookie JSON。

```python
# 无头模式（七鱼客服等不需要 WAF 的页面）
context = await browser.launch_persistent_context(
    user_data_dir=CHROME_PROFILE,
    headless=True
)

# 可见模式（support 发票页等需要 WAF 的页面）
subprocess.Popen([
    chrome_path,
    f"--user-data-dir={CHROME_PROFILE}",
    "--remote-debugging-port=9228",
])
```

---

## 三、Skill 能力与数据依赖矩阵

| 能力 | 能力编号 | 依赖数据 | 读/写 | 需要用户手动登录 |
|------|---------|---------|-------|----------------|
| Steam 版本管理 | ① | 无 | - | 否 |
| 奇想手账监控 | ② | nuan_profile.json + chrome-profile | 读 / 写（nuan_journal.json） | 仅 Cookie 过期时 |
| 探索进度查询 | ③ | chrome-profile | 读 / 写（nuan_explore.json） | 仅 Cookie 过期时 |
| 抽卡查询 | ④ | nuan_gacha_stats.json / nuan_gacha_history.json | 读 / 写 | 仅初始抓取时 |
| 公开信息 - 兑换码 | ⑤ | 无 | - | 否 |
| 公开信息 - 氪条查询 | ⑤ | nuan_profile.json（support 分支）+ chrome-profile | 读 / 写（nuan_recharge_history.json） | 仅 Cookie 过期时 |

---

## 四、首次运行初始化逻辑

Agent 在首次使用 Skill 时触发：

```
1. 检测 USER_DATA_DIR 是否存在
   ├─ 存在 → 跳过初始化
   └─ 不存在 → 创建目录结构

2. 检测 nuan_profile.json 是否存在
   ├─ 存在 → 检查 Cookie 有效性
   └─ 不存在 → 引导用户打开可见 Chrome 登录
               myl.nuanpaper.com
               登录完成后提取 Cookie 写入 nuan_profile.json

3. 检测 chrome-profile\ 是否存在
   ├─ 存在 → 复用
   └─ 不存在 → 自动创建空目录
```

---

## 五、数据写入规则

| # | 规则 | 说明 |
|---|------|------|
| 1 | **只增补不覆写** | `nuan_profile.json`、`nuan_recharge_history.json` 等标注"只增补"的文件，只能追加新条目，严禁覆写或删除已有条目 |
| 2 | **快照可覆盖** | `nuan_gacha_stats.json`、`nuan_gacha_history.json`、`nuan_journal.json`、`nuan_explore.json` 为最新快照，爬取时覆盖更新 |
| 3 | **Cookie 只存 nuan_profile.json** | 禁止将 Cookie 写入其他文件或硬编码在脚本中 |
| 4 | **路径统一变量** | 所有脚本统一引用 `USER_DATA_DIR` 常量，不得硬编码路径 |
