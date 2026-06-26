# 奇想手账抽卡查询 — Agent 执行参考

> **主数据源**：`<SKILL_DIR>\user-data\nuan_gacha_stats.json`（React fiber 直接爬取）
> **辅助参考**：`<SKILL_DIR>\user-data\nuan_gacha_history.json`（原始导出，三星已过滤）
> **网页来源**：https://myl.nuanpaper.com/tools/journal/clothesPress

## 查询流程

```
用户输入昵称 → ai_search 确认正式名 → nuan_gacha_stats.json 匹配 → 格式化输出
```

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1. 接收昵称 | 如"花套""鸟套""圣女套" | 社区约定俗称的简称 |
| 2. 联网确认 | `ai_search` 搜索"无限暖暖 + 昵称" | 确认正式名称，避免歧义 |
| 3. 数据匹配 | 在 `nuan_gacha_stats.json` 中按 `suit_name` 精确匹配 | 五星/四星各自独立数组 |
| 4. 输出 | 返回统计信息 | 套装名、星级、平均共鸣、总计共鸣 |

## 输出字段

| 字段 | 来源 | 说明 |
|------|------|------|
| 套装名 | `suit_name` | 正式名称 |
| 星级 | `rarity` | 5 或 4 |
| 平均共鸣次数 | `avg_resonance` | 单件平均抽数 |
| 总计共鸣次数 | `total_resonance` | 全套装总抽数 |

## 数据文件

### gacha_stats_raw.json（主数据源）

**提取方法**：遍历 DOM 中 `.cardWrpaper` 元素 → 读取 `__reactFiber` → 从 React fiber 树提取：

| React 字段 | 含义 | 对应 JSON 字段 |
|------------|------|----------------|
| `suitItem.level` | 星级（5/4） | `rarity` |
| `suitItem.totalDrawNum` | 总计共鸣次数（整数） | `total_resonance` |
| `suitItem.averageDrawNum` | 平均共鸣次数（浮点） | `avg_resonance` |
| `suitItem.partsCount` | 套装总部件数 | `parts_count` |
| `suitItem.name` | 套装名称 | `suit_name` |

**统计**：五星 31 个 + 四星 69 个 = 100 个。

### gacha_history.json（辅助参考）

原始抽卡导出，`pool_cnt` 为 0-based。`total_pulls` 字段不可靠，三星记录已被奇想手账过滤。

## 已知限制

- **垫抽不可见**：三星重复抽卡被完全过滤，无法计算真正的垫抽数
- **parts_count 是总部件数**：非用户已收集部件数
- **数据需定期更新**：`nuan_gacha_stats.json` 为静态快照，需重新抓取
