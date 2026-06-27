<p align="right">
  <a href="README_EN.md">English</a>
</p>
<br /><br />

<p align="center">
  <img src="icon.png" width="128" alt="NuanSkill" />
</p>

<h1 align="center">NuanSkill</h1>
<h3 align="center">无限暖暖综合管理 AI Agent Skill</h3>

<p align="center">
  <strong>Infinity Nikki All-in-One AI Agent Skill</strong>
</p>

<p align="center">
  <em>Steam 版本管理（ACF 反更新 · SteamDB 自动检测 · 骨架化清理）+ 奇想手账（体力 · 美鸭梨 · 抽卡统计 · 探索进度）+ 公开信息查询（兑换码 · 氪条）</em>
</p>

<p align="center">
  <sub>v1.3.1 · Windows 10/11 · Marvis / QClaw 已测试 · 更多 Agent 适配中</sub>
</p>

<p align="center">
  <sub>包括本文档及代码在内均包含 AI 辅助生成。不代表本人立场。</sub>
</p>

---

<br />

<p align="center">
  <strong>NuanSkill 能做什么？</strong><br /><br />
  ▸ <strong>Steam 管理</strong>：伪造 ACF 版本信息 + 自动抓取 SteamDB 最新 BuildID/Manifest GID，一键版本同步<br />
  ▸ <strong>空间清理</strong>：骨架化清理 Steam 壳目录，X6Game 外置备份，随时可还原<br />
  ▸ <strong>奇想手账</strong>：体力提醒、美鸭梨挖掘进度、抽卡记录查询、探索进度查询，全部自然语言交互<br />
  ▸ <strong>公开信息</strong>：兑换码实时查询、氪条消费记录查询（近 6 个月订单明细）<br />
  ▸ <strong>微信远程调用</strong>：连接 Marvis + 微信 Clawbot，随时随地通过微信操作<br />
  ▸ <strong>零依赖</strong>：单文件 PowerShell 脚本，配置内嵌，无外部文件依赖
</p>

<br />

---

## 📋 导航

- [30 秒快速上手](#30-秒快速上手)
- [安装到 Marvis](#安装到-marvis)
- [用自然语言操作](#用自然语言操作)
- [功能详解](#功能详解)
- [脚本命令参考](#脚本命令参考)
- [注意事项](#注意事项)
- [常见问题 FAQ](#常见问题-faq)
- [版本历史](#版本历史)
- [参考链接](#参考链接)

---

## 30 秒快速上手

### 第一步：获取 Skill

```powershell
# 方式一：Git 克隆（推荐）
git clone https://github.com/qtqtEricChiu/nuanskill-infinitynikki-helper.git

# 方式二：下载 ZIP
# 访问 https://github.com/qtqtEricChiu/nuanskill-infinitynikki-helper 点击 Code → Download ZIP
```

### 第二步：试试看

成功导入到你的 Agent 后（导入方法见[安装说明](#安装说明)），在对话框中输入：

```
「帮我检查一下无限暖暖的 Steam 版本状态」
```

Agent 会自动执行检测并汇报结果。

---

## 安装说明

> 当前 v1.3.1 已在 Marvis / QClaw 平台完成测试。其他 Agent 平台的理论支持见下方说明。

### 检查奇想手账连接状态

> 首次使用本 Skill 时，必须先完成奇想手账的登录初始化。Agent 会自动引导流程：打开可见 Chrome 窗口，等待您手动登录后提取 Cookie 并持久化。
>
> **抽卡记录首次爬取**需要遍历所有历史抽卡页面，预计 5-15 分钟，爬取完成后数据保存到本地，后续查询无需重新爬取。

### Marvis（✅ 已测试）

1. 确保 Marvis 已更新至最新版本
2. 打开 Marvis → **技能广场** → **Skill 库** → **我的技能**
3. 点击「**导入技能**」
4. 在弹出的导入窗口中，点击「**点击导入**」或切换到「**手动导入**」Tab 选择本地文件夹
5. 定位到 `nuanskill-infinitynikki-helper/` 文件夹，确认导入
6. 导入成功后，在 Skill 列表中看到「NuanSkill」
7. 确保 Skill 状态为「**已启用**」

> 💡 **导入后修改不会自动同步**：修改 Skill 文件后需重新导入覆盖方可生效。

### QClaw（✅ 已测试）

1. 打开 QClaw 设置 → **技能管理**
2. 选择「**本地导入**」或「**从 Github 导入**」
3. 定位到 `nuanskill-infinitynikki-helper/` 文件夹或输入 Git 仓库地址
4. 导入成功后即可使用

### 微信远程调用

支持通过 Clawbot 实现**远程通过微信调用本 Skill**（兼容 Marvis、QClaw 等支持 Claw 协议的 Agent 平台）：

1. 在您的 Agent 中完成 Skill 导入并启用
2. 参考对应 Agent 的官方文档绑定微信 Clawbot
3. 绑定后，在微信中直接与 Clawbot 对话即可触发 NuanSkill 的各项能力

```
微信 → Clawbot → Agent（已加载 NuanSkill）→ 执行操作 → 微信回复结果
```

典型远程场景：

| 场景 | 微信中说 |
|------|----------|
| 出门在外查体力 | 「我无限暖暖现在体力多少？」 |
| 推送更新提醒 | Clawbot 主动推送 Steam 版本更新提醒 |
| 远程触发检测 | 「帮我检查一下无限暖暖要不要更新」 |

### 其他 Agent 平台（⚠️ 理论支持，待测试）

| Agent | 导入方式 | 状态 |
|-------|----------|------|
| OpenClaw | 文件夹路径 / Git URL | 待测试 |
| WorkBuddy | Skill 导入接口 | 待测试 |

如果你的平台不在以上列表，请参考对应 Agent 的 Skill 导入文档，或直接联系我添加支持。

---

## 用自然语言操作

导入 Skill 后，直接用中文和 Agent 对话即可。以下是真实使用场景示例：

### Steam 管理

| 你想做什么 | 直接说 |
|-----------|--------|
| 检查当前版本状态 | 「帮我检查一下无限暖暖的 Steam 版本」 |
| 更新到最新版本 | 「把 ACF 更新到最新版本」 |
| 查看 ACF 详情 | 「显示 ACF 的完整信息」 |
| 清理 Steam 目录空间 | 「帮我清理一下 Steam 目录空间」 |
| 预览骨架化操作 | 「骨架化之前先帮我看看会动哪些文件」 |
| 还原 X6Game | 「还原 X6Game 到 Steam 目录」 |
| 锁定/解锁 ACF | 「锁定 ACF」/ 「解锁 ACF」 |
| 全面检查 | 「帮我全面验证一下配置对不对」 |

### 奇想手账

| 你想做什么 | 直接说 |
|-----------|--------|
| 查体力 | 「现在体力多少，什么时候回满？」 |
| 美鸭梨挖掘 | 「美鸭梨还要挖多久？」 |
| 抽卡统计 | 「花套我抽了多少发？」 |
| 模糊查询 | 「帮我查一下有『星』字的套装抽卡记录」 |
| 列出所有套装 | 「列出我所有套装的抽卡统计」 |
| 查锚点进度 | 「心愿原野的流转之柱开完了吗？」 |
| 查探索进度 | 「奇想星收集了多少？」 |
| 查区域收集 | 「伊赞之土的灵感露珠还差多少？」 |

### 公开信息

| 你想做什么 | 直接说 |
|-----------|--------|
| 查兑换码 | 「有没有最新的兑换码？」 |
| 查氪条 | 「我氪了多少，帮我查一下消费记录」 |

---

## 功能详解

### Steam 管理

#### 为什么需要 ACF 反更新？

无限暖暖 Steam 中国版（AppID: **3164330**）通过 `%command%` 高级启动关联国服启动器。Steam 只负责启动壳，核心数据由国服独立管理。

**问题**：每次官方更新后，Steam 检测到本地版本低于云端，触发完整下载覆盖（~110 GB），但实际上核心数据由国服管理，Steam 壳只需保持版本号同步即可。

**解决**：修改 `appmanifest_3164330.acf`，让 Steam 认为本地已是最新：

| ACF 字段 | 设置值 | 作用 |
|----------|--------|------|
| `StateFlags` | `4` | 状态：已安装就绪 |
| `TargetBuildID` | `0` | 不要求更新到特定版本 |
| `buildid` | SteamDB 最新值 | 匹配云端最新 Public BuildID |
| `InstalledDepots` → `manifest` | SteamDB 最新 GID | 匹配 Depot 3164332 最新 Manifest |
| `AutoUpdateBehavior` | `1` | 仅启动时检查更新 |
| 文件只读属性 | ON | 阻止 Steam 改写 ACF |

#### 骨架化清理

Steam 壳目录中，`InfinityNikki\X6Game\` 占用 ~110 GB，但游戏运行时实际读取的是国服目录。

骨架化将 `X6Game` 移至同盘备份位置（`{盘符}\X6Game_backup`），释放 Steam 目录空间。保留启动器必需文件（`launcher.exe`、`steam_appid.txt` 等），Steam 仍可正常启动游戏。

> 💡 移动是同盘物理移动（NTFS 移动），速度极快，不是复制。

#### SteamDB 自动检测流程

```
1.  检测 Steam 是否运行 → 是则自动 steam -shutdown 退出
2.  读取本地 ACF，提取当前 buildid 和 manifest GID
3.  启动 Google Chrome（--remote-debugging-port=9222）
    → 使用独立 Chrome Profile（不干扰你的日常浏览器）
    → 自动打开 SteamDB depot 页面
4.  通过 Chrome CDP WebSocket 注入 JavaScript 提取页面数据
5.  正则解析提取最新 Public buildid 和 Manifest GID
6.  对比本地版本
    → 匹配：无需操作，直接汇报
    → 不匹配：备份 ACF → 更新字段 → 锁定只读
7.  同步 SizeOnDisk 为实际目录大小
```

访问 SteamDB 超时时，自动执行网络诊断（Ping + DNS + 代理检测）。

### 奇想手账监控

通过 Chrome（`Cache\chrome_temp_profile\` 专用凭据）访问 `https://myl.nuanpaper.com/tools/journal`，自动完成：

| 功能 | 说明 |
|------|------|
| 体力监控 | 提取当前体力值，用 PowerShell `Get-Date` 精确计算回满时间 |
| 美鸭梨挖掘 | 提取挖掘进度，计算完成时间 |
| 抽卡记录查询 | 支持昵称→正式名映射（「花套」→「花焰之诗」），精确/模糊查询 |

> ⚠️ 奇想手账网页端不显示三星重复记录，垫抽数据无法获取，查询结果为已确认记录统计。

### 探索进度查询

通过 Chrome（`Cache\chrome_temp_profile\` 专用凭据）访问奇想手账「探索总览」标签页（第 2 个标签），提取各区域探索数据：

| 维度 | 说明 |
|------|------|
| 流转之柱（锚点） | 各区域传送锚点开启进度 X/Y |
| 奇想星 | 地图散落收集进度 X/Y |
| 灵感露珠 | 地图散落收集进度 X/Y |
| 子区域收集项 | 气球/结晶/气泡/凝珠/玉琚/玉魄等 X/Y |

> **数据保存策略**：每次查询时，Agent 自动将当前页面所有探索数据保存到 `user-data/nuan_explore_data.json`。缓存有效期 7 天，可随定时任务定期更新。

### 公开信息查询

通过 Chrome（`Cache\chrome_temp_profile\`）访问两个不同来源获取公开信息：

| 功能 | 说明 |
|------|------|
| 兑换码查询 | 自动获取当前有效兑换码列表、福利内容和有效期 |
| 氪条查询 | 查询近 6 个月充值订单明细，结果持久化保存 |

> **消费历史持久化**：每次氪条查询结果自动追加到 `user-data/nuan_recharge_history.json`，只增补不覆写，可追溯历史查询记录。

---

## 脚本命令参考

所有脚本从技能根目录执行。以下为直接运行 PowerShell 的参考，通过 Agent 操作时无需手动输入这些命令。

### nuanskill-infi-manager.ps1

Steam 全功能管理（单文件、零外部依赖，配置已内嵌）：

```powershell
.\scripts\nuanskill-infi-manager.ps1 <命令> [选项]
```

| 命令 | 说明 |
|------|------|
| `status` | 显示 ACF 状态、Steam 运行检测、X6Game 位置、独立启动器信息 |
| `steamdb-check` | 全自动：启动 Chrome → 爬取 SteamDB → 对比 → 更新 ACF → 锁定只读 |
| `update` | 手动更新 ACF（需同时提供 `-BuildID` 和 `-ManifestGID`） |
| `skeletonize` | 将 X6Game 移至同盘备份，释放空间 |
| `skeletonize -DryRun` | 预览骨架化操作，不实际执行 |
| `restore` | 从备份还原 X6Game 到 Steam 目录 |
| `lock` / `unlock` | 锁定 / 解锁 ACF 只读属性 |
| `verify` | 7 项健康检查，确认所有配置正确 |
| `report` | 生成完整状态报告 |
| `residual-check` | 检测是否有残留文件 |
| `query` | 显示 SteamDB 手动查询链接 |

**常用选项**：

| 选项 | 说明 |
|------|------|
| `-Force` | 跳过确认提示，直接执行 |
| `-DryRun` | 模拟运行，不实际修改任何文件 |
| `-BuildID <值>` | 手动指定 BuildID（配合 `update` 命令） |
| `-ManifestGID <值>` | 手动指定 Manifest GID（配合 `update` 命令） |

### nuanskill-gacha-lookup.ps1

查询套装抽卡统计（数据来源：`user-data/nuan_gacha_stats.json`）：

```powershell
.\scripts\nuanskill-gacha-lookup.ps1 "花焰之诗"
.\scripts\nuanskill-gacha-lookup.ps1 --list
```

### nuanskill-time-calc.ps1

体力回满预测 + 美鸭梨挖掘完成时间：

```powershell
.\scripts\nuanskill-time-calc.ps1 120        # 当前体力 120，计算回满时间
.\scripts\nuanskill-time-calc.ps1 --dig-all # 计算美鸭梨全部挖掘完成时间
```

---

## 注意事项

| # | 事项 |
|---|------|
| 1 | **操作前必须完全退出 Steam**（含 `steamwebhelper` 进程），否则 ACF 无法修改 |
| 2 | ACF 只读锁定后 Steam 无法改写，如需让 Steam 正常更新，先执行 `unlock` |
| 3 | Steam 内「游戏属性 → 更新」建议设为「**仅在我启动时更新此游戏**」 |
| 4 | 脚本修改 ACF 前自动在 `backups\` 目录生成 `.bak` 备份文件 |
| 5 | 骨架化移动是同盘物理移动，速度极快，但不会跨盘 |
| 6 | 每次官方更新后需重新执行 SteamDB 检测（`steamdb-check`） |
| 7 | 奇想手账 Cookie 过期时需重新登录，更新 `user-data/nuan_cookie_nuanpaper.json` |
| 8 | **抽卡记录首次爬取较慢**：第一次爬取需要遍历所有历史抽卡页面，预计 5-15 分钟。爬取完成后数据保存到 `user-data/nuan_gacha_stats.json`，后续查询直接读取本地，无需重新爬取 |
| 9 | **首次使用需手动登录**：`nuan_cookie_nuanpaper.json` 不存在时，Agent 会打开可见 Chrome 引导您完成奇想手账登录（含验证码），登录后自动提取 Cookie 持久化 |
| 10 | **定时任务推荐**：创建自动任务时（如每月更新抽卡记录），可一并更新探索进度数据（`nuan_explore_data.json`），保持本地数据最新 |
| 11 | `Cache/` 和 `user-data/` 不纳入版本控制（已加入 `.gitignore`） |

---

## 常见问题 FAQ

### Q：ACF 反更新会不会被 Steam 检测为作弊？
A：不会。修改的是本地的 `appmanifest` 文件，仅影响 Steam 客户端的版本判断，不涉及游戏内存或网络封包。

### Q：骨架化会删除我的游戏数据吗？
A：不会。X6Game 是**移动**到同盘备份位置，随时可以用 `restore` 命令还原。

### Q：为什么需要 Google Chrome？
A：SteamDB 的检测依赖 Chrome CDP（Chrome DevTools Protocol）自动抓取页面数据。如果你用其他 Chromium 内核浏览器（Edge/Brave 等），可在脚本中手动指定路径。

### Q：奇想手账的 Cookie 多久过期？
A：通常为 7~30 天，取决于叠纸的服务端策略。过期后 Agent 会自动提示重新登录。

### Q：抽卡查询为什么说「无结果」？
A：先确认套装名称是否正确。Agent 会自动将昵称映射为正式名（参考 `references/nuanskill-gacha-query.md`），但如果是非常新的套装，可能尚未收录。

### Q：可以跨平台使用吗（Mac / Linux）？
A：目前仅支持 Windows 10/11，因为依赖 PowerShell 和 Windows 路径格式。

### Q：抽卡记录第一次查为什么慢？
A：首次爬取需要遍历所有历史抽卡页面，预计 5-15 分钟。爬取完成后数据保存到本地，后续查询瞬间返回。

### Q：探索进度数据会过期吗？
A：流转之柱（锚点）和收集物不会像体力一样每天变化，本地缓存有效期建议 7 天。每次查询时 Agent 会自动更新本地缓存。

### Q：这个项目开源吗？
A：暂未声明开源许可证，当前以 GitHub 公开仓库形式发布，仅供学习和个人使用。开源协议将在后续讨论后添加。

---

## 版本历史

完整版本历史详见 `CHANGELOG.md`。

当前版本：**v1.3.1（2026-06-28）**。

---

## 参考链接

- [无限暖暖官方网站](https://infinitynikki.infoldgames.com/)
- [SteamDB — App 3164330](https://steamdb.info/app/3164330/)
- [SteamDB — Sub 1221922](https://steamdb.info/sub/1221922/)
- [SteamDB — Depot 3164332](https://steamdb.info/depot/3164332/manifests/)
- [奇想手账](https://myl.nuanpaper.com/)
- [技术原理：Steam 游戏更新机制与 ACF 文件](https://cloud.tencent.com/developer/article/2468980)
- [InfiSteam（本项目的独立桌面程序版）](https://github.com/qtqtEricChiu/InfiSteam)

---

## 相关项目

### [InfiSteam](https://github.com/qtqtEricChiu/InfiSteam)

无限暖暖 Steam 高级启动管理工具（独立桌面程序版）

- 提供 WinUI 3 / WPF 桌面版 + AI Agent 提示词
- 适合不喜欢 AI Agent 交互、偏好图形界面的用户
- 本 Skill 的 Steam 管理核心逻辑来源于此项目

### [InfiMouse](https://github.com/qtqtEricChiu/InfiMouse)

游戏画面录制助手 — Windows 鼠标轨迹控制与同步输入工具

- 基于 WinUI 3 + Bezier 曲线规划高度拟人化鼠标轨迹
- 支持键盘事件时间轴同步 + Xbox 虚拟手柄注入
- 反检测人性化（抖动、速度方差、overshoot、随机暂停）
- 适合游戏画面录制、自动化演示场景
- 技术栈：C# / WinUI 3 / MVVM / SendInput / XInput

---

<p align="center">
  <sub>
    本工具与 <strong>叠纸游戏</strong> / <strong>Infold Games</strong>、<strong>SteamDB</strong> 以及 <strong>Valve Corporation</strong> 无关。<br />
    无限暖暖 © 2024 Papergames, ALL RIGHTS RESERVED. Steam 为 Valve Corporation 的商标。
  </sub>
</p>
