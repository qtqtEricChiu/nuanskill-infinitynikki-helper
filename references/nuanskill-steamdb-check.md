# 奇想手账 SteamDB 版本检测 — Agent 执行参考

> **能力编号**：能力①
> ©mocabolka 2026. 本工具与 Valve / Steam、SteamDB、叠纸游戏 / Infold Games 无关。仅供学习交流使用，使用时请注意个人数据安全，时刻检测 Agent 文件操作安全性。

> **前置提醒**：操作前必须提示用户在 Steam 客户端内完成：
> **游戏库 → 右键游戏 → 属性 → 更新 → 自动更新 → 设为「等到我启动游戏时」**

## 路径约定

所有相对路径基于**本文件所在文件夹**（即技能目录）。临时目录/文件必须在此文件夹下创建，严禁写入 `$env:TEMP` 等系统路径。

## 前置条件检查

### 检测 Steam 安装

```powershell
# 注册表检测（最准确）
$steamPath = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
if (-not $steamPath) {
    $steamPath = (Get-ItemProperty "HKCU:\SOFTWARE\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
}

# 常见安装路径备选
$commonPaths = @(
    "C:\Program Files (x86)\Steam", "C:\Program Files\Steam",
    "D:\Steam", "D:\Entertainment\Steam", "$env:LOCALAPPDATA\Steam"
)
foreach ($p in $commonPaths) { if (Test-Path "$p\steam.exe") { $steamPath = $p; break } }

# 进程定位
if (-not $steamPath) {
    $p = (Get-Process steam -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    if ($p) { $steamPath = Split-Path $p }
}
```

### 查找游戏库（多库支持）

从 `libraryfolders.vdf` 提取所有库路径，查找 `appmanifest_3164330.acf`：

```powershell
$vdf = "$steamPath\steamapps\libraryfolders.vdf"
$libs = @($steamPath)
if (Test-Path $vdf) {
    $libs += Select-String '"path"\s+"([^"]+)"' $vdf | ForEach-Object { $_.Matches.Groups[1].Value }
}
$acfPath = $null; $gameDir = $null
foreach ($lib in $libs) {
    $acf = "$lib\steamapps\appmanifest_3164330.acf"
    if (Test-Path $acf) { $acfPath = $acf; $gameDir = "$lib\steamapps\common\Infinity Nikki"; break }
}
```

### 版本类型判断（中国版 vs 国际版）

```powershell
$isChina = $acfContent -match '"sub/1221922"' -or $acfContent -match 'schinese'
if (-not $isChina) {
    $paks = "$gameDir\InfinityNikki\X6Game\Content\Paks"
    $isChina = (Test-Path $paks) -and (Get-ChildItem $paks -Filter "*China*").Count -gt 0
}
```

## ACF 字段参考

| 字段 | 期望值 | 说明 |
|------|--------|------|
| `buildid` | SteamDB 最新 | 构建版本号 |
| `manifest` | SteamDB 最新 | Depot manifest GID (19位) |
| `StateFlags` | 4 | 已安装就绪 |
| `TargetBuildID` | 0 | 无待更新目标 |
| `AutoUpdateBehavior` | 1 | 等到启动时更新 |
| `BytesToDownload` | 0 | 清零 |
| `BytesDownloaded` | 0 | 清零 |
| `BytesToStage` | 0 | 清零（关键！否则 Steam 仍提示更新） |
| `BytesStaged` | 0 | 清零（同上） |
| `SizeOnDisk` | 自动同步 | 更新时自动计算 |

## SteamDB 数据获取（CDP 协议）

```powershell
# 1. 查找 Chrome
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromeExe)) { $chromeExe = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" }

# 2. 启动 Chrome（远程调试模式）
$profileDir = Join-Path $PSScriptRoot "Cache\chrome_temp_profile"
Start-Process $chromeExe -ArgumentList @(
    "--remote-debugging-port=9222",
    "--user-data-dir=`"$profileDir`"",
    "--no-first-run", "--no-default-browser-check",
    "https://steamdb.info/app/3164330/depots/"
) -WindowStyle Normal

# 3. 等待 CDP 就绪
$maxWait = 30; $waited = 0
while ($waited -lt $maxWait) {
    try { $r = Invoke-RestMethod "http://127.0.0.1:9222/json/version" -ErrorAction Stop; break }
    catch { Start-Sleep 1; $waited++ }
}
```

### Cloudflare 验证处理

检测到 "Checking your browser" / "Just a moment" / "请稍候" 等关键词时，自动等待验证完成（最长 120 秒，每 2 秒检测一次）。

### 数据提取

```powershell
# 解析 Depots 页面 → BuildID
$steamdbBuildID = [regex]::Match($depotsText, 'public\s+(\d+)').Groups[1].Value

# 导航到 Manifests 页面 → Manifest GID
# 通过 CDP Page.navigate 跳转到 https://steamdb.info/depot/3164332/manifests/
$steamdbManifest = [regex]::Match($manifestsText, '(\d{19})').Groups[1].Value
```

## ACF 更新流程

```powershell
# 1. 备份
$backupPath = Join-Path $backupDir ("appmanifest_3164330.acf.bak." + (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item $acfPath $backupPath

# 2. 解除只读
Set-ItemProperty $acfPath -Name IsReadOnly -Value $false

# 3. 修改字段
$acf = $acf -replace '("buildid"\s+")\d+(")', "`${1}$steamdbBuildID`$2"
$acf = $acf -replace '("manifest"\s+")\d+(")', "`${1}$steamdbManifest`$2"
$acf = $acf -replace '("TargetBuildID"\s+")\d+(")', '${1}0$2'
$acf = $acf -replace '("StateFlags"\s+")\d+(")', '${1}4$2'
# 清零下载/暂存字段
@("BytesToDownload","BytesDownloaded","BytesToStage","BytesStaged") | ForEach-Object {
    $acf = $acf -replace """$_\""\s+""\d+""", """$_""		""0"""
}

# 4. 同步 SizeOnDisk
$actualSize = (Get-ChildItem $gameDir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$acf = $acf -replace '("SizeOnDisk"\s+")\d+(")', "`${1}$actualSize`$2"

# 5. 写入 + 重新锁定
Set-Content $acfPath -Value $acf -Encoding UTF8 -NoNewline
Set-ItemProperty $acfPath -Name IsReadOnly -Value $true
```

## 验证清单

1. ACF 文件存在
2. `StateFlags` = 4
3. `TargetBuildID` = 0
4. `AutoUpdateBehavior` = 1
5. ACF 为只读
6. 游戏目录存在
7. launcher.exe / steam_appid.txt 等关键文件存在
8. 骨架化状态（X6Game 是否已移出）

## 骨架化（空间清理）

将 `InfinityNikki\X6Game` 移至同盘 `X6Game_backup` 目录：

```powershell
# 使用 infi-manager.ps1
.\scripts\nuanskill-infi-manager.ps1 skeletonize        # 执行
.\scripts\nuanskill-infi-manager.ps1 skeletonize -DryRun # 预览
.\scripts\nuanskill-infi-manager.ps1 restore             # 还原
```

## 独立启动器检测

三种方法检测（由 `scripts\nuanskill-infi-manager.ps1` 自动执行）：
1. **注册表**：扫描 `HKLM/HKCU\Uninstall` 下 DisplayName 含 `Infinity`/`Nikki`/`Infold` 的条目
2. **config.ini**：常见目录下查找 `config.ini` 解析 `game_path`
3. **开始菜单**：扫描 `.lnk` 快捷方式

检测到后生成 Steam 启动选项：`"{路径}" %command%`

## 残留文件检查

需要检查的残留目录（在 steamapps 目录下）：
- `appmanifest_3164330.acf.*.tmp` — ACF 临时文件
- `appmanifest_3164330.acf.bak.*` — ACF 备份文件
- `downloading\3164330` — 下载临时目录
- `temp\3164330` — 临时目录

## 网络诊断（超时处理）

当 SteamDB 访问超时时执行（4 种超时阈值）：
- Chrome 启动超时：30 秒
- 页面加载超时：60 秒
- CDP 通信超时：30 秒
- Cloudflare 验证超时：30 秒（之后执行网络诊断）

```powershell
# Ping 延迟检测
Test-Connection steamdb.info -Count 4
Test-Connection cloudflare.com -Count 4

# DNS 解析检测
Resolve-DnsName steamdb.info

# 代理检测
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | Select-Object ProxyEnable, ProxyServer
```

## 自动清理（流程结束前）

Agent **必须自动执行**以下清理（无需询问用户）：

```powershell
# 删除 SteamDB 缓存
@("steamdb_depots.txt","steamdb_manifests.txt") | ForEach-Object {
    $p = Join-Path $PSScriptRoot $_; if (Test-Path $p) { Remove-Item $p -Force }
}
# 删除 ACF 备份
Get-ChildItem (Join-Path $PSScriptRoot "backups") -Filter "appmanifest_3164330.acf.bak.*" -ErrorAction SilentlyContinue |
    ForEach-Object { Remove-Item $_.FullName -Force }
# 注意：不清理 Cache\chrome_temp_profile，该目录为奇想手账与 SteamDB 共用，
# 删除会导致其他能力的登录凭据丢失。仅清理 SteamDB 临时文件即可。
```
