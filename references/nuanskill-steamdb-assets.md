# Steam 商店资源下载 — Agent 执行参考

> **能力编号**：能力①（子技能）
> **窗口模式**：必须使用**可见 Chrome 窗口**（Cloudflare Turnstile interactive 验证）
> **前置参考**：Chrome 启动、CDP 连接、CF 验证等通用操作见 `references/nuanskill-browser.md`
>
> **本文索引**
> - [任务目标与前置条件](#任务目标与前置条件)
> - [7 类资产对照](#7-类资产对照)
> - [策略优先级](#策略优先级)
> - [路径 A：SteamDB 页面提取](#路径-asteamdb-页面提取)
> - [路径 B：CDN 猜测 + 商店 API](#路径-bcdn-猜测--商店-api)
> - [下载与打包](#下载与打包)
> - [通用扩展（其他 AppID）](#通用扩展其他-appid)
> - [踩坑清单](#踩坑清单)

---

## 任务目标与前置条件

从 SteamDB/Steam CDN 下载指定游戏的商店展示资产（capsule、hero、logo、header、背景图），打包为 ZIP 存入用户 Downloads 文件夹。

**前置条件**（复用能力①的 Chrome 初始化流程）：
1. 可见 Chrome 窗口已启动（`--remote-debugging-port=9228`）
2. Playwright `connect_over_cdp` 已连接
3. 若 Cloudflare Turnstile 拦截，通知用户手动完成验证

**输入**：`AppID`（数字）
**输出**：`{Downloads}\steam_assets_{AppID}_{label}_{YYYYMMDD}.zip`

---

## 7 类资产对照

| 资产名 | 用途 | SteamDB 文件名特征 | 猜测法 URL 模式 | 商店 API 字段 |
|--------|------|-------------------|----------------|--------------|
| `library_capsule` | 库封面 | `library_capsule`, `library_600x900` | `library_600x900_schinese.jpg` 等 | — |
| `library_hero` | 库横幅 | `library_hero` | `library_hero_schinese.jpg` 等 | — |
| `library_logo` | 游戏 Logo | `logo_` | `logo_schinese.png` 等 | — |
| `library_header` | 库顶栏 | `library_header` | `library_header_schinese.jpg` 等 | — |
| `page_bg` | 页面背景 | `page_bg`, `page_bg_raw` | 同 hero_capsule | `background_raw` |
| `main_capsule` | 商店主胶囊 | `header_` | 同 library_header | `header_image` |
| `hero_capsule` | 商店英雄图 | `hero_capsule`, `page_bg_raw` | 同 page_bg | `background_raw` |

**schinese 优先级**：`schinese_2x_schinese` > `schinese_2x` > `schinese` > `tchinese` > 无语言后缀

---

## 策略优先级

> **SteamDB 页面提取（路径 A）> CDN 猜测 + 商店 API（路径 B）**

- **路径 A**：通过可见 Chrome 访问 SteamDB info 页面，从页面 DOM 中提取完整 CDN URL（含 hash 路径）。这是唯一能拿到带 hash 的真实 URL 的方式，对路径特殊的游戏（如锁区游戏）必须用此路径。
- **路径 B**：当无法连接可见 Chrome、或页面无内容时，用多 CDN × 多文件名变体猜测 + Steam 商店 API 补充作为兜底。

---

## 路径 A：SteamDB 页面提取

### 1. 连接可见 Chrome + 访问页面

```
1. Playwright connect_over_cdp → 可见 Chrome（端口 9228）
2. 打开新 tab，访问 https://steamdb.info/app/{appid}/info/
3. 等待页面加载（wait_until="domcontentloaded"）
```

### 2. Cloudflare 验证检测

SteamDB 使用 Cloudflare Turnstile（`cType: interactive`），无头浏览器无法自动通过。

```
1. 轮询 document.title，最长 120 秒，每 2 秒检查一次
2. 若 title 包含"请稍候"/"Checking"/"Just a moment" → CF 未通过
   ├─ 通知用户：弹框提示去浏览器窗口手动完成人机验证
   └─ 用户确认后 → 回到步骤 1 继续轮询
3. 若 title 显示真实页面名（如"Infinity Nikki · SteamDB"）→ CF 已通过，继续
```

> **踩坑**：`domcontentloaded` 时 DOM 可能为空壳（仅 11KB）。必须轮询 `document.title` 确认 CF 通过，不可依赖 `wait_for_selector`。

### 3. 提取 CDN URL

```
1. page.evaluate 收集所有 <img src> 和 <a href> 中
   包含 steamstatic / steamcdn / akamai 的 URL
2. 若链接数 = 0 → 页面无内容，降级到路径 B
3. 若链接数 > 0 → 按文件名关键词分类到 7 类资产

分类规则（按文件名包含关键词）：
  library_capsule / library_600x900 → library_capsule
  library_hero                       → library_hero
  logo_                              → library_logo
  library_header                     → library_header
  page_bg / page_bg_raw             → page_bg
  header_                            → main_capsule
  hero_capsule / page_bg_raw        → hero_capsule
```

### 4. 筛选最优语言变体

同类资产有多个 URL 时，按优先级选择：
1. 文件名含 `schinese` → 优先
2. 文件名含 `tchinese` → 次选
3. 无语言后缀 → 通用回退

---

## 路径 B：CDN 猜测 + 商店 API

### B1：CDN URL 猜测（library assets）

从以下 CDN 基地址逐一遍历候选文件名：

```
尝试顺序（共享 CDN → Cloudflare CDN）：
1. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{appid}/
2. https://cdn.cloudflare.steamstatic.com/steam/apps/{appid}/
```

> **踩坑**：部分游戏（如 4162040）仅在 `shared.fastly` 带 hash 路径下存在文件，猜测法只能用无 hash 的单层路径，library assets 可能全失败。这是路径 B 的固有局限。

每个资产的候选文件名（schinese_2x → schinese → 通用回退）：

**library_capsule：**
`library_600x900_schinese.jpg`, `library_600x900_2x_schinese.jpg`, `library_600x900.jpg`, `library_600x900_2x.jpg`, `capsule_616x353_schinese.jpg`, `library_capsule_schinese_2x.jpg`

**library_hero：**
`library_hero_schinese_2x.jpg`, `library_hero_schinese.jpg`, `library_hero_2x.jpg`, `library_hero.jpg`

**library_logo：**
`logo_schinese_2x.png`, `logo_schinese.png`, `logo_2x.png`, `logo.png`

**library_header：**
`library_header_schinese_2x.jpg`, `library_header_schinese.jpg`, `library_header_2x.jpg`, `library_header.jpg`

**page_bg：**
`page_bg_raw.jpg`, `page_bg.jpg`

**main_capsule：**
`header_schinese_2x.jpg`, `header_schinese.jpg`, `header_2x.jpg`, `header.jpg`

**hero_capsule：**
优先从 B2 商店 API 获取；回退 `hero_capsule_schinese_2x.jpg` 等

### B2：Steam 商店 API 补充（store assets）

```
GET https://store.steampowered.com/api/appdetails?appids={appid}
```

从返回 JSON 的 `{appid}.data` 中提取：
- `header_image` → `main_capsule` 的直接 URL，直接下载
- `background_raw` → `hero_capsule` 和 `page_bg` 的直接 URL，直接下载

> **踩坑**：未发布/锁区游戏可能返回 `success=false`，此时仅依赖路径 A。

---

## 下载与打包

### 获取 Downloads 路径

```
1. 读注册表 Shell Folders：
   HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
   项 {374DE290-123F-4565-9164-39C4925E467B}
2. 回退到：%USERPROFILE%\Downloads
```

### 下载

对每类资产获得的最终 URL 执行 HTTP GET，写入临时目录。失败时跳过该类资产（不阻塞整体流程）。

### 打包

```
1. 临时目录路径：{PSScriptRoot}\temp_assets\
2. ZIP 文件名：steam_assets_{appid}_{game_label}_{yyyyMMdd}.zip
3. 目标路径：{Downloads}\{ZIP 文件名}
4. 清理临时目录
```

---

## 通用扩展（其他 AppID）

本流程适用于任意 Steam AppID。通用化处理要点：

| 要素 | 处理方式 |
|------|---------|
| **AppID** | 由用户输入或通过搜索游戏名从商店 API 获取 |
| **游戏标签** | 从商店 API 返回的 `name` 字段提取，用于 ZIP 文件名 |
| **schinese 优先** | 对所有游戏均适用（候选文件名含 schinese 变体），不存在时自动降级 |
| **路径 A 回退** | 任何游戏只要能通过 CF 验证，SteamDB 页面都可提取完整 hash URL |
| **路径 B 局限** | 锁区/未发布游戏在 CDN 猜测层可能失败，但路径 A 仍可成功 |

---

## 踩坑清单

| # | 问题 | 现象 | 根因 | 解法 |
|---|------|------|------|------|
| 1 | **无头 CF 不过** | 永远停在"Checking your browser" | CF Turnstile interactive，需人工交互 | 可见 Chrome + 弹框通知用户验证 |
| 2 | **domcontentloaded 空壳** | `page.content()` 仅 11KB，0 图片 | SteamDB 页面 JS 动态渲染，DOM 未就绪 | 轮询 `document.title` 变化，不应依赖 wait_for_selector |
| 3 | **CDP WebSocket 403** | `websocket.create_connection` 被拒 | Chrome 启动参数缺 `--remote-allow-origins` | 用 Playwright `connect_over_cdp` 替代裸 WebSocket |
| 4 | **library_capsule 变体特殊** | `library_capsule.jpg` 在标准 CDN 路径不存在 | 实际文件名为 `library_600x900_schinese.jpg` | 候选文件名必须包含 `library_600x900_*` 变体 |
| 5 | **部分游戏 CDN 路径含 hash** | CDN 单层路径下无文件 | 资产仅在 `shared.fastly` 带 hash 路径存在 | 只能通过路径 A（SteamDB 提取）解决 |
| 6 | **hero_capsule 映射** | 不知道从哪获取该资产 | 对应 API `background_raw`，不是 CDN 独立文件 | 路径 B2 商店 API 补充时正确映射 |
| 7 | **API 间歇性 failure** | 返回 `success=false` | 未知（锁区/状态变更），后会恢复 | 失败时不做致命判断，走其他路径继续 |
| 8 | **CF 弹框时机** | 用户不知道何时去验证 | ask_user 时机不对 | 检测到 CF 阻塞时立即弹框通知 |

---

©mocabolka 2026. 与 Valve / Steam、SteamDB、叠纸游戏 / Infold Games 无关。仅供学习交流。
