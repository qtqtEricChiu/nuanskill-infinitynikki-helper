# 奇想手账已知问题与踩坑记录

> **能力编号**：能力⑤
> 记录开发过程中遇到的问题、根因分析及最终解决方案，供后续维护参考。

## 1. pool_cnt 规律（已确认）

**规律**：`max(pool_cnt) + 1 = 网页总计共鸣次数`，对**新套装成立**。

**验证**：大多数卡池符合此规律。不匹配的套装（如炽羽不渝偏差 +45、龙隐云墨间偏差 +1）均为**较老套装**，属于历史离群值。后续更新的新抽卡记录均遵循 `max+1` 规律。

**结论**：`pool_cnt` 可作为新套装的可靠推算依据，老套装仍需以网页直接爬取为准。

---

## 2. 网页数据抓取 — 数字拼接错误

### 现象

使用 `innerText` 提取数字时出现严重拼接：

| 套装 | 正确值 | 错误值 | 拼接来源 |
|------|--------|--------|----------|
| 予梦心时 | 19 | 191 | "19" + "1"（进度分数 `1/10` 首位） |
| 龙隐云墨间 | 94 | 945 | "94" + "5"（进度分数 `5/10` 首位） |
| 落入泪之潮 | 94 | 945 | "94" + "5"（进度分数 `5/10` 首位） |
| 雪境长歌 | 84 | 845 | "84" + "5"（进度分数 `5/11` 首位） |

### 根因

React 页面渲染后，`innerText` 将总计共鸣次数与紧邻进度分数（如 `5/10`）的首位数字粘合——DOM 文本节点在 `innerText` 计算时发生字符串拼接。

### 修复

完全绕过 `innerText`，改用 React fiber 直接读取结构化数据：

```
遍历 .cardWrpaper → __reactFiber → suitItem.totalDrawNum（精确整数）
```

---

## 3. 网页数据抓取 — 星级分类错误

**现象**：早期版本未按页面 UI 的"五星共鸣套装"/"四星共鸣套装" tab 区分数据，导致予梦心时等被误判为四星。

**修复**：从 `suitItem.level` 直接读取星级（5/4），与页面 tab 完全一致。

---

## 4. 垫抽不可见

三星重复抽卡被奇想手账完全过滤，以下途径均无法获取：

- `gacha_history.json` 原始导出
- 网页端 clothesPress 页面
- 任何其他奇想手账入口

所有统计数据仅基于可见的四星/五星记录，真正的垫抽数无法计算。

---

## 5. 时间计算兜底

**问题**：环境信息中的"当前日期"可能滞后于实际系统时间。

**规则**：涉及时间推算必须先执行：

```powershell
Get-Date -Format "yyyy-MM-dd HH:mm:ss"
```

严禁依赖环境信息中的日期。影响范围：体力满格时间、美鸭梨完成时间、任何倒计时计算。

---

## 6. localStorage 提取 — 无头模式可用（已实测验证）

**现象**：无头 Chrome 调用 `localStorage.getItem('journal')`，返回值与可见窗口完全一致（raw 1,587,504 字符、574 条记录、100 个卡池）。

**结论**：**无头 Chrome 可正常读取 clothesPress 的 localStorage**，不需要弹窗。之前认为必须可见窗口的判断被实测推翻。

**当前推荐**：使用无头 Chrome + Cookie 注入即可，静默完成不打扰用户。流程：

```
无头 Chrome → 注入 Cookie → 加载 clothesPress 页面 → 等待渲染完成 → eval(localStorage.getItem('journal'))
```

---

## 7. localStorage 数据 — 编码损坏

**现象**：`suitCardListData`（卡池/套装明细）中的部分中文字段出现乱码，如 UTF-8 字节被按 Latin-1 解码后存为 &#xxxx; 实体。

**根因**：Redux persist 序列化时发生了 UTF-8 / Latin-1 双重编码错误，仅影响 `pool_summary` 中的中文字段。

**影响范围**：仅 `pool_summary` 的中文字段显示异常，`card_pool_id`、数字字段、`gacha_list` 的抽卡记录完好无损。

**处理方案**：持久化时保持原始值不动，不做额外解码尝试。因为：
- 结构 ID 和数值字段完整可用
- 乱码不影响 Agent 的卡池匹配逻辑（按 `card_pool_id` 匹配）
- 尝试修复可能引入二次损坏

---

## 8. localStorage 数据源 — 不需要 API 请求

**现象**：尝试通过抓包或 API 调用的方式获取抽卡历史数据，得到的 URL 返回 404 或空数据。

**根因**：clothesPress 页面的抽卡数据在页面加载时由 Redux 从 `localStorage` 恢复，**不发网络请求**。API 端点 `myl-api.nuanpaper.com/v1/strategy/user/info/get` 并非数据源。

**修复**：直接读取 `localStorage.getItem('journal')`，无需拦截网络请求或调用任何 API。

---

## 9. 满进判断 — evolution_suit_id 不可信

**现象**：使用 `evolutions1/2/3` 中的 `evolution_suit_id` 非空判断满进，结果错误（常驻四套五星全判为满进，实际只有一套满进）。

**根因**：`evolutions` 中的字段（`image`、`evolution_suit_id`、`evolution_suit_name`）只是预设元数据，**不是达成状态标记**。这些预设值对所有玩家相同，无论是否已获取进化材料。

**正确判断规则**：

满进 = `firstSuit` 全部 `drawNum > 0` 且 `secondSuit` 全部 `drawNum > 0`

即第二套每个部件都已实际抽出才算满进。

```
for each 卡池 (level=5):
    fs_got = count(firstSuit, where drawNum > 0)
    ss_got = count(secondSuit, where drawNum > 0)
    满进 ⇔ fs_got == len(firstSuit) AND ss_got == len(secondSuit)
```

| 错误做法 | 正确做法 |
|---------|---------|
| 用 `evolution_suit_id` 非空判断满进 | 用 `secondSuit.drawNum > 0` 判断 |
| evolutions 字段存在即视为已达成 | evolutions 只是预设元数据，不代表已获得 |

**常驻五星参考值**：满进需要 18 件（firstSuit 9 件 + secondSuit 9 件），晶莹诗集需要 20 件（10+10）。

---

## 10. gacha_list 中常驻池 rarity 为 0

**现象**：常驻池（card_pool_id=1）的抽卡记录在 `gacha_list` 中 `rarity` 字段为 `0`（不是 4 或 5）。

**影响**：无法按星级筛选常驻池记录，只能通过 `card_pool_id` 归类区分常驻与限定。
