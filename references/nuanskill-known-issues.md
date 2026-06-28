# 已知问题与踩坑记录

> **能力编号**：通用（踩坑参考，所有能力均可查阅）
>
> **本文索引**
> - [通用踩坑](#通用踩坑)
> - [能力① Steam 管理](#能力-steam-管理)
> - [能力④ 抽卡查询](#能力-抽卡查询)
> - [能力⑤ 公开信息](#能力-公开信息)

---

## 通用踩坑

### 1. 时间计算兜底 [通用]

**问题**：环境信息中的"当前日期"可能滞后于实际系统时间。

**规则**：涉及时间推算必须先执行：

```powershell
Get-Date -Format "yyyy-MM-dd HH:mm:ss"
```

严禁依赖环境信息中的日期。影响范围：体力满格时间、美鸭梨完成时间、任何倒计时计算。

---

### 2. Cloudflare Turnstile interactive 验证 [通用]

**现象**：SteamDB 使用 interactive 类型 Turnstile，无头浏览器永远停在"Checking your browser"无法通过。

**根因**：Turnstile 设为 `cType: interactive`，必须人工交互。

**解法**：使用可见 Chrome（`--remote-debugging-port=9228`），检测到 CF 阻塞时弹框通知用户手动完成验证。轮询 `document.title` 最长 120 秒，不可依赖 `wait_for_selector`（domcontentloaded 时 DOM 可能仅 11KB 空壳）。

---

### 3. CDP WebSocket 403 [通用]

**现象**：`websocket.create_connection` 被 Chrome 拒绝（403）。

**根因**：Chrome 启动参数缺 `--remote-allow-origins`，Playwright 的 `connect_over_cdp` 会自动处理此问题。

**解法**：改用 Playwright `browser = await p.chromium.connect_over_cdp("http://127.0.0.1:{port}")`，不要用裸 WebSocket。

---

### 4. 第三方 SPA 页面 DOM 刷新 [通用]

**现象**：snapshot ref 在动态页面上失效，click ref 报错。

**根因**：SPA 页面 DOM 频繁刷新，之前定位的元素引用已失效。

**解法**：通过 eval + CSS 选择器定位元素兜底，不依赖之前保存的 snapshot ref。

---

### 5. 昵称→正式名映射 — 视觉误导 [通用]

**现象**：用户说「小红帽套」时，Agent 因看到「红色 + 帽子」的视觉印象错误指向「绯夜狂想录」，正确映射是「她是不驯火」。

**根因**：先入为主的视觉判断、搜索结果被干扰后未深挖、未做交叉验证。

**正确搜索流程**：
1. 搜「昵称 + 无限暖暖 + 套装」→ 排除杂鱼
2. 结果模糊 → 换「昵称 + 五星」「昵称 + 无限暖暖」再搜
3. 有候选正式名 → 搜「候选名 + 昵称」交叉验证
4. 优先高权威来源（官网文章、正规游戏媒体），不凭视觉印象
5. 多条来源一致确认后再返回

| 昵称 | 容易误判 | 正确映射 |
|------|---------|---------|
| 小红帽 | 绯夜狂想录（玩偶套，红色+帽子） | 她是不驯火 |

---

## 能力① Steam 管理

### 6. SteamDB 自动清理 [①]

**注意**：`{USER_DATA_DIR}chrome-profile` 为奇想手账与 SteamDB 共用，删除会导致其他能力的登录凭据丢失。流程清理时仅清理 SteamDB 临时文件（缓存/备份），**禁止**清理 Chrome profile 目录。

---

### 7. library_capsule 变体特殊 [①]

**现象**：`library_capsule.jpg` 在标准 CDN 路径不存在。

**根因**：该资产实际文件名为 `library_600x900_schinese.jpg`，非 `library_capsule`。

**解法**：猜测法候选文件名必须包含 `library_600x900_*` 变体。

---

### 8. 部分游戏 CDN 路径含 hash [①]

**现象**：`cdn.cloudflare.steamstatic.com/steam/apps/{appid}/` 下无任何文件。

**根因**：资产仅在 `shared.fastly.steamstatic.com/store_item_assets/` 带 hash 路径下存在。

**解法**：猜测法无法获取（缺 hash），只能依赖 SteamDB 页面提取（路径 A）。

---

### 9. hero_capsule 字段映射 [①]

**现象**：不知道该从哪获取 hero_capsule 资产。

**根因**：对应商店 API `background_raw` 字段，不是 CDN 上的独立文件。

**解法**：路径 B2 商店 API 补充时正确映射 `background_raw` → hero_capsule。

---

### 10. 商店 API 间歇性 failure [①]

**现象**：未发布/锁区游戏返回 `success=false`。

**根因**：未知（锁区、状态变更），后会恢复正常。

**解法**：失败时不做致命判断，走路径 A（SteamDB 提取）继续。

---

### 11. CF 弹框时机 [①]

**现象**：用户不知道何时该去浏览器完成人机验证。

**根因**：ask_user 通知时机不对。

**解法**：检测到 CF 阻塞时立即弹框，告知"请在浏览器窗口中完成人机验证"。

---

## 能力④ 抽卡查询

### 12. pool_cnt 规律 [④]

**规律**：`max(pool_cnt) + 1 = 网页总计共鸣次数`，对**新套装成立**。

**验证**：大多数卡池符合此规律。不匹配的套装（如炽羽不渝偏差 +45、龙隐云墨间偏差 +1）均为**较老套装**，属于历史离群值。后续更新的新抽卡记录均遵循 `max+1` 规律。

**结论**：`pool_cnt` 可作为新套装的可靠推算依据，老套装仍需以网页直接爬取为准。

---

### 13. innerText 数字拼接错误 [④]

**现象**：使用 `innerText` 提取数字时出现严重拼接。例如龙隐云墨间正确值 94 被拼接为 945。

**根因**：React 页面渲染后，`innerText` 将总计共鸣次数与紧邻进度分数的首位数字粘合。

**修复**：完全绕过 `innerText`，改用 React fiber 直接读取结构化数据。

---

### 14. 星级分类错误 [④]

**现象**：早期版本未按页面 UI 的 tab 区分数据，导致予梦心时等被误判为四星。

**修复**：从 `suitItem.level` 直接读取星级（5/4），与页面 tab 完全一致。

---

### 15. 垫抽不可见 [④]

三星重复抽卡被奇想手账完全过滤，以下途径均无法获取：
- `nuan_gacha_history.json` 原始导出
- 网页端 clothesPress 页面
- 任何其他奇想手账入口

所有统计数据仅基于可见的四星/五星记录，真正的垫抽数无法计算。

---

### 16. localStorage 提取 — 无头模式可用 [④]

**结论**：无头 Chrome 可正常读取 clothesPress 的 localStorage，不需要弹窗。使用无头 Chrome + Cookie 注入即可，静默完成不打扰用户。

---

### 17. localStorage 编码损坏 [④]

**现象**：`suitCardListData` 中的部分中文字段出现乱码。

**根因**：Redux persist 序列化时发生 UTF-8 / Latin-1 双重编码错误。

**处理**：持久化时保持原始值不动，不做额外解码尝试。结构 ID 和数值字段完整可用，不影响 Agent 的卡池匹配逻辑。

---

### 18. localStorage 不需要 API 请求 [④]

**现象**：尝试通过抓包或 API 调用获取抽卡历史数据，得到的 URL 返回 404 或空数据。

**根因**：clothesPress 页面的抽卡数据在页面加载时由 Redux 从 `localStorage` 恢复，**不发网络请求**。

**修复**：直接读取 `localStorage.getItem('journal')`，无需拦截网络请求或调用任何 API。

---

### 19. 满进判断 — evolution_suit_id 不可信 [④]

**现象**：使用 `evolutions` 中的字段非空判断满进，结果错误。

**根因**：`evolutions` 中的字段只是预设元数据，**不是达成状态标记**，对所有玩家相同。

**正确规则**：满进 = `firstSuit` 全部 `drawNum > 0` 且 `secondSuit` 全部 `drawNum > 0`。

| 错误做法 | 正确做法 |
|---------|---------|
| 用 `evolution_suit_id` 非空判断满进 | 用 `secondSuit.drawNum > 0` 判断 |

---

### 20. gacha_list 中常驻池 rarity 为 0 [④]

**现象**：常驻池（card_pool_id=1）的抽卡记录在 `gacha_list` 中 `rarity` 字段为 `0`（不是 4 或 5）。

**影响**：无法按星级筛选常驻池记录，只能通过 `card_pool_id` 归类区分常驻与限定。

---

## 能力⑤ 公开信息

### 21. 七鱼客服 iframe 数字拼接 [⑤]

**现象**：七鱼客服 iframe 中的数字同样存在 innerText 拼接问题。

**根因**：与奇想手账同理，DOM 文本节点拼接。

**解法**：提取兑换码详情时，取匹配全文的最后一次出现作为该条详情，避开首位干扰。

---

### 22. 无头不可用（阿里云 WAF） [⑤]

**现象**：support 发票页无头浏览器无法访问。

**根因**：`aliyungf_tc` WAF 检测无头特征后拦截，httpOnly 无法注入。

**解法**：必须使用可见 Chrome。

---

### 23. 氪条查询等待不可靠 [⑤]

**现象**：切换日期后无法用 `wait_for_selector` 等待数据加载。

**根因**：数据通过异步 XHR 回填，无特定 DOM 事件可监听。

**解法**：轮询页面文本是否变为所选日期范围，且表格不再显示"暂无"。

---

### 24. Cookie 时效性 [⑤]

**现象**：`aliyungf_tc` 为 httpOnly 且经常刷新，不能跨会话复用注入。

**解法**：登录态通过 `{USER_DATA_DIR}chrome-profile\` 持久化 Profile 整体保存，而非单独存 cookie JSON。

---

### 25. 兑换码无历史公告 [⑤]

客服机器人只回复当前有效兑换码，不提供历史记录，无法查询已过期的兑换码。

---

### 26. 依赖 iframe URL 稳定性 [⑤]

七鱼 iframe URL 可能随版本更新变化，需定期验证。

---

### 27. React + iframe 渲染时间长 [⑤]

兑换码页面 React + iframe 嵌套加载需等待，`wait_for_selector` 建议 timeout=15000。若超时则重试一次。
