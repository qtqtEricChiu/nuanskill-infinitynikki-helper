# 数据文件格式规范

> **能力编号**：通用（所有能力写入 user-data 时必须遵循）
>
> Agent 写入 `user-data/` 下所有 JSON 文件时**必须严格遵循以下格式**，不得增删字段、改变字段名或嵌套层级。

---

## nuan_cookie_nuanpaper.json（[通用] nuanpaper.com Cookie 凭据）

按子域名分组存储，每个子域名下以时间戳命名条目。**只能增补，严禁覆写或删除已有条目**。

```json
{
  "myl": {
    "subdomain": "myl.nuanpaper.com",
    "note": "奇想手账（通用），cookies只能增补，严禁覆写删除",
    "current_YY-MM-DD": {
      "cookies": {
        "momoToken": "字符串",
        "momoOpenid": "字符串",
        "momoNid": "字符串",
        "momoVisitor": "字符串"
      }
    },
    "previous_YY-MM-DD": {
      "cookies": { ... }
    },
    "previous_YY-MM-DD_1": {
      "cookies": { ... }
    }
  },
  "support": {
    "subdomain": "support-infinitynikki.nuanpaper.com",
    "note": "客服中心（nuanpaper）（能力⑤），cookies只能增补，严禁覆写删除",
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
  }
}
```

> 命名规则：`current_` / `previous_` + 日期（YY-MM-DD）。若同一日期有多条，追加 `_1`、`_2` 后缀。**新增条目时绝对不可覆写或删除旧条目**。
>
> `myl` 子域名：奇想手账通用 Cookie（能力②③④共用）。
> `support` 子域名：客服中心 Cookie（能力⑤使用）。
>
---

## nuan_cookie_papegames.json（[通用] papegames.com Cookie 凭据）

暂不分子域名，按时间戳直接存放。**只能增补，严禁覆写或删除已有条目**。

```json
{
  "note": "cookies只能增补，严禁覆写删除",
  "current_YY-MM-DD": {
    "cookies": {}
  }
}
```

> 命名规则：`current_` / `previous_` + 日期（YY-MM-DD）。后续访问 papegames.com 域名后在此填充具体 cookie 字段。

---

## nuan_gacha_stats.json（[能力④] 抽卡统计）

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

## nuan_gacha_history.json（[能力④] 抽卡历史）

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

## nuan_journal_data.json（[能力②] 日程缓存）

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

## nuan_explore_data.json（[能力③] 探索进度）

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

## nuan_recharge_history.json（[能力⑤] 氪条消费历史）

按查询时间戳分组存储，每次查询结果作为一条历史记录追加。**只能增补，严禁覆写或删除已有条目**。

```json
{
  "note": "消费历史持久化存储，只能增补，严禁覆写删除",
  "records": [
    {
      "queried_at": "2026-06-28T14:30:00（ISO 时间字符串）",
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
