# 浏览器操作通用参考

> **能力编号**：通用（所有能力需要浏览器访问时统一参考）
>
> **核心原则**：所有浏览器操作使用 `{USER_DATA_DIR}chrome-profile\` 持久化 Profile，与其他 Skill/浏览器完全隔离。禁止使用用户系统默认 Chrome Profile。
>
> **本文索引**
> - [浏览器查找与降级](#浏览器查找与降级)
> - [启动 Chrome（两种模式）](#启动-chrome两种模式)
> - [CDP 连接](#cdp-连接)
> - [端口分配规则](#端口分配规则)
> - [Cloudflare 验证处理](#cloudflare-验证处理)
> - [Cookie 提取](#cookie-提取)
> - [关闭与清理](#关闭与清理)

---

## 浏览器查找与降级

优先使用 Google Chrome，找不到时按顺序降级：

```
├─ Google Chrome（chrome.exe）                            ← 首选
│   检查路径：C:\Program Files\Google\Chrome\Application\chrome.exe
│            C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
├─ Microsoft Edge（msedge.exe）                            ← 降级一
│   检查路径：C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
├─ Brave / Vivaldi 等 Chromium 内核                         ← 降级二
└─ agent 内置浏览器                                        ← 最终降级
     适用场景：无头 + Cookie 注入模式（无 --user-data-dir）
```

> 无论使用哪种浏览器，`--user-data-dir` 必须始终指向 `{USER_DATA_DIR}chrome-profile\`。切换浏览器只改变可执行文件路径，不改变用户数据目录。

---

## 启动 Chrome（两种模式）

### 可见窗口模式（Cloudflare WAF / 手动登录）

```powershell
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$profileDir = "{USER_DATA_DIR}chrome-profile"
$port = [具体值见端口分配表]

Start-Process $chromeExe -ArgumentList @(
    "--remote-debugging-port=$port",
    "--user-data-dir=`"$profileDir`"",
    "--no-first-run", "--no-default-browser-check",
    "https://目标URL"
) -WindowStyle Normal
```

### 无头模式（普通数据抓取）

无头模式时无需独立启动 Chrome，直接通过 Playwright 打开即可：

```python
context = await p.chromium.launch_persistent_context(
    user_data_dir=CHROME_PROFILE,
    headless=True
)
page = await context.new_page()
await page.goto("https://目标URL")
```

> 无头模式可绕过 Cloudflare 的基本防护，但无法通过 interactive 类型的 Turnstile（如 SteamDB）和阿里云 WAF（如 support 发票页）。

---

## CDP 连接

启动 Chrome 后通过 Chrome DevTools Protocol 控制浏览器：

```python
# Playwright 方式（推荐）
browser = await p.chromium.connect_over_cdp("http://127.0.0.1:{port}")
page = await browser.new_page()

# 或裸 WebSocket（仅 CDP 高级操作需要）
import websocket
ws = websocket.create_connection("ws://127.0.0.1:{port}/devtools/page/...")
```

**等待 CDP 就绪**：Chrome 启动后需要等待远程调试端口可访问：

```
轮询 http://127.0.0.1:{port}/json/version
最长等待 30 秒，每 1 秒重试一次
成功 → 继续
超时 → 报告 Chrome 启动失败
```

> **踩坑**：必须使用 `connect_over_cdp` 而非裸 WebSocket。Chrome 的 `--remote-allow-origins` 参数可能不包含请求来源，导致 WebSocket 返回 403。Playwright 的 connect_over_cdp 自动处理了此问题。

---

## 端口分配规则

多个浏览器场景可能同时运行（如用户切换窗口），必须使用不同端口避免冲突。

| 端口 | 用途 | 窗口模式 | 触发时机 |
|------|------|---------|---------|
| 9222 | SteamDB 版本检测（depots/manifests） | 可见 | 用户要求 Steam 版本修复时 |
| 9228 | SteamDB 商店资源下载（info 页面） | 可见 | 用户要求下载游戏资产时 |
| 9230 | support 发票页（氪条查询） | 可见 | 用户要求查询氪条时 |
| 9232 | myl 奇想手账登录初始化 | 可见 | Cookie 过期需重新登录时 |

> 同一端口不得同时用于两个任务。若目标端口已被占用，自动递增到下一个可用端口（+1 步进）。

---

## Cloudflare 验证处理

部分目标站点（SteamDB、support.nuanpaper.com）使用 Cloudflare 防护，无头模式无法通过。

### 检测 CF 拦截

```
1. 页面加载后读取 document.title
2. 若 title 包含以下关键词之一 → CF 未通过：
   - "请稍候" / "Checking" / "Just a moment" / "验证"
3. 若 title 为真实页面标题 → CF 已通过
```

### 等待 CF 通过

```
1. 轮询 document.title，最长 120 秒，每 2 秒检查一次
2. 若 CF 未通过：
   ├─ 通知用户：弹框提示去 Chrome 窗口手动完成人机验证
   └─ 用户确认后 → 继续轮询
3. 若 CF 通过 → 继续后续操作
```

## 防护类型与绕过策略

| 防护类型 | 判定方法 | 绕过策略 | 无头可用 | 典型站点 |
|---------|---------|---------|:-------:|---------|
| 无防护 | 页面直接渲染 | 直接访问 | ✅ | myl.nuanpaper.com 普通页面 |
| Cloudflare 基本 JS 验证 | title 出现"请稍候"/"Checking"但很快消失 | 无头浏览器自动执行 JS 即可通过 | ✅ | — |
| Cloudflare Turnstile（non-interactive） | 页面可见勾选"我不是机器人"（隐藏式） | 无头浏览器自动完成 | ✅ | 七鱼客服 iframe 等 |
| Cloudflare Turnstile（interactive） | 页面弹出图片选择/点击验证 | **必须可见 Chrome + 人工交互** | ❌ | **SteamDB** |
| 阿里云 WAF（aliyungf_tc） | 页面白屏或重定向，`aliyungf_tc` Cookie 为 httpOnly | **必须可见 Chrome**，WAF 检测无头特征后拦截 | ❌ | **support-infinitynikki发票页** |

### Cloudflare Turnstile（interactive）详细说明

**判定流程：**

```
1. 页面加载后轮询 document.title
2. 若 5 秒后 title 仍为"请稍候..." / "Checking your browser" → 判定为 Turnstile interactive
3. 持续轮询最多 120 秒，每 2 秒检查一次
4. 若超时仍未通过 → 弹框通知用户手动完成验证
```

**绕过流程：**

```
1. 确保 Chrome 为可见窗口
2. 通知用户："请在浏览器窗口中完成人机验证（勾选或点击图片）"
3. 用户手动完成验证后，页面自动加载
4. 轮询检测 document.title 变为真实页面名后继续
```

### 阿里云 WAF 详细说明

support 发票页使用阿里云 WAF，`aliyungf_tc` Cookie 为 httpOnly 属性，无法通过 JavaScript `document.cookie` 读取，也不能跨会话复用注入。

```
┌─ 无头模式 ─────────────────────────────┐
│  阿里云 WAF 检测到无头特征 → 直接拦截    │
│  页面白屏 / 返回 403 / 跳转验证页        │
└─────────────────────────────────────────┘

┌─ 可见 Chrome（推荐） ───────────────────┐
│  WAF 放行正常浏览器                     │
│  httpOnly Cookie 由 Chromium 原生管理    │
│  下次复用 {USER_DATA_DIR}chrome-profile\ │
│  即可保持登录态，无需重新验证             │
└─────────────────────────────────────────┘
```

> **关键**：阿里云 WAF 的 `aliyungf_tc` 为 httpOnly 且经常刷新，不能跨会话复用注入。登录态通过 `{USER_DATA_DIR}chrome-profile\` 持久化 Profile 整体保存，而非单独存 cookie JSON。

---

## Cookie 提取

### 适用场景

- 用户首次登录 myl.nuanpaper.com 后提取登录凭据
- Cookie 过期后重新登录后提取新凭据
- 从已登录的可见 Chrome 中提取任意子域名的 Cookie

### 操作流程

```
前置条件：可见 Chrome 已连接 CDP（端口分配见上表）

1. 打开目标页面（如 https://myl.nuanpaper.com/tools/journal/login）
2. 等待用户手动完成登录（含验证码等人机环节）
3. 登录成功后，通过 CDP 提取 Cookie：

   const cookies = await page.evaluate(() => {
       return document.cookie.split('; ').reduce((acc, c) => {
           const [k, v] = c.split('=');
           acc[k] = v;
           return acc;
       }, {});
   });

4. 从返回中提取所需字段（momoToken / momoOpenid / momoNid / momoVisitor）
5. 按 nuan_profile.json 格式写入 {USER_DATA_DIR}nuan_profile.json
```

### 提取时机

| 场景 | 提取页面 | 提取后动作 |
|------|---------|-----------|
| 首次初始化 | `myl.nuanpaper.com/tools/journal/login` | 写入 `myl.nuanpaper.com` 分支 |
| Cookie 过期后重登 | 同上 | 追加为 `previous_YY-MM-DD` 条目 |
| 需要 support Cookie | `support-infinitynikki.nuanpaper.com` | 写入 `support-infinitynikki.*` 分支 |

> **只增补**：Cookie 写入 nuan_profile.json 时只追加新条目，严禁覆写或删除已有记录。

---

## 关闭与清理

| 场景 | 操作 | 说明 |
|------|------|------|
| 无头模式 | 自动释放 | `await browser.close()`，框架自动清理 |
| 可见窗口（独占） | 关闭标签页 + 保留浏览器 | 用户可能正在其他标签页操作 |
| 可见窗口（本 Skill 独占） | 关闭整个浏览器 | 确认无其他标签页在使用 |
| Chrome 进程残留 | `Stop-Process -Name chrome -Force` | 仅当明确知道无其他任务使用当前 Profile 时执行 |

> 规则 #7 要求：若被其他 Skill 唤出了有头浏览器，在整理输出结果前必须先将浏览器窗口关闭（除非用户要求保留）。
