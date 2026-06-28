<p align="right">
  <a href="README.md">中文</a>
</p>
<br /><br />

<p align="center">
  <img src="icon.png" width="128" alt="NuanSkill" />
</p>

<h1 align="center">NuanSkill</h1>
<h3 align="center">Infinity Nikki All-in-One AI Agent Skill</h3>

<p align="center">
  <strong>无限暖暖综合管理 AI Agent Skill</strong>
</p>

<p align="center">
  <em>Steam Version Management (ACF Anti-Update · SteamDB Auto-Detect · Skeletonize Cleanup) + Journal Tools (Stamina · Digging · Gacha Stats · Exploration Progress) + Public Info Query (Coupon Codes · Recharge History)</em>
</p>

<p align="center">
  <sub>v1.4.0 · Windows 10/11 · Marvis / QClaw Tested · More Agents Adapting</sub>
</p>

<p align="center">
  <sub>This document and code may contain AI-assisted content. Does not represent personal views.</sub>
</p>

---

<br />

<p align="center">
  <strong>What Can NuanSkill Do?</strong><br /><br />
  ▸ <strong>Steam Management</strong>: Forge ACF version info + auto-fetch latest BuildID/Manifest GID from SteamDB, one-click version sync + asset download<br />
  ▸ <strong>Space Cleanup</strong>: Skeletonize Steam shell directory, external X6Game backup, restorable anytime<br />
  ▸ <strong>Journal Tools</strong>: Stamina reminders, Digging progress, Gacha record queries, Exploration progress — all via natural language<br />
  ▸ <strong>Public Info</strong>: Real-time coupon code query, Recharge history query (last 6 months order details)<br />
  ▸ <strong>WeChat Remote</strong>: Connect Marvis + WeChat Clawbot, operate from anywhere via WeChat<br />
  ▸ <strong>Zero Dependencies</strong>: Single-file PowerShell scripts, built-in config, no external file dependencies
</p>

<br />

---

## 📋 Table of Contents

- [Quick Start in 30 Seconds](#quick-start-in-30-seconds)
- [Installation](#installation)
- [Natural Language Commands](#natural-language-commands)
- [Feature Details](#feature-details)
- [Script Command Reference](#script-command-reference)
- [Important Notes](#important-notes)
- [FAQ](#faq)
- [Changelog](#changelog)
- [Reference Links](#reference-links)

---

## Quick Start in 30 Seconds

### Step 1: Get the Skill

```powershell
# Option 1: Git Clone (Recommended)
git clone https://github.com/qtqtEricChiu/nuanskill-infinitynikki-helper.git

# Option 2: Download ZIP
# Visit https://github.com/qtqtEricChiu/nuanskill-infinitynikki-helper → Code → Download ZIP
```

### Step 2: Try It Out

After importing to your Agent (see [Installation](#installation) for import instructions), type in the dialog:

```
"Check the Steam version status for Infinity Nikki"
```

The Agent will automatically run diagnostics and report results.

---

## Installation

> v1.4.0 has been tested on **Marvis** and **QClaw**. Other platforms are theoretically supported.

### First-Time Setup

> On first use, you must complete the Journal login initialization. The Agent will guide you through: it opens a visible Chrome window, waits for you to log in manually, then extracts and persists the Cookie.
>
> **First gacha crawl** takes 5-15 minutes (traversing all pull history). Data is saved locally afterwards — subsequent queries read from cache instantly.

### Marvis (✅ Tested)

1. Make sure Marvis is updated to the latest version
2. Open Marvis → **Skill Plaza** → **Skill Library** → **My Skills**
3. Click **Import Skill**
4. In the popup, click **Click to Import**, or switch to **Manual Import** tab to select local folder
5. Navigate to `nuanskill-infinitynikki-helper/` folder, confirm import
6. "NuanSkill" appears in the skill list
7. Ensure skill status is **Enabled**

> 💡 **Changes don't auto-sync**: Re-import the skill folder to apply modifications.

### QClaw (✅ Tested)

1. Open QClaw Settings → **Skill Management**
2. Select **Local Import** or **Import from Github**
3. Navigate to `nuanskill-infinitynikki-helper/` folder or enter the Git repo URL
4. Ready to use after import

### WeChat Remote Access

Supports **remote skill invocation via WeChat through Clawbot** (compatible with Marvis, QClaw, and other Claw-compatible Agent platforms):

1. Import and enable the skill in your Agent
2. Bind WeChat Clawbot per your Agent's official documentation
3. Chat with Clawbot in WeChat to trigger NuanSkill features

```
WeChat → Clawbot → Agent (NuanSkill loaded) → Execute → Reply to WeChat
```

Typical remote scenarios:

| Scenario | Say in WeChat |
|----------|---------------|
| Check stamina from outside | "How much stamina does my Infinity Nikki have?" |
| Update push notification | Clawbot pushes Steam version update alerts |
| Remote trigger check | "Check if Infinity Nikki needs an update" |

### Other Agent Platforms (⚠️ Theoretically Supported, Untested)

| Agent | Import Method | Status |
|-------|---------------|--------|
| OpenClaw | Folder path / Git URL | Untested |
| WorkBuddy | Skill import interface | Untested |

---

## Natural Language Commands

Once the skill is imported, just talk to the Agent in natural language. Here are real usage scenarios:

### Steam Management

Steam version repair is a **linear flow from detection to lock**. The Agent runs the full chain on any of these requests:

| What You Want | Say This |
|---------------|----------|
| **Full version repair (recommended)** | "Check/update/fix the Steam version for Infinity Nikki" |
| Check Steam status | "What's the Steam version status?" / "Show ACF" |
| Clean space | "Clean up Steam directory space" / "Skeletonize" |
| Restore X6Game | "Restore X6Game to the Steam directory" |

### Journal Tools

| What You Want | Say This |
|---------------|----------|
| Check stamina | "How much stamina do I have? When will it refill?" |
| Digging progress | "How much longer on the dig?" |
| Gacha stats | "How many pulls for [outfit name]?" |
| Fuzzy search | "Search gacha records containing 'star'" |
| List all outfits | "List all my outfit gacha stats" |
| Check warp spires | "Are the warp spires in [region] all unlocked?" |
| Check exploration | "How many Whimstars have I collected?" |
| Check regional collectibles | "How many Inspiration Dews left in [region]?" |

### Public Info

| What You Want | Say This |
|---------------|----------|
| Check coupon codes | "Any new coupon codes available?" |
| Check recharge history | "How much have I spent? Check my recharge history." |

---

## Feature Details

### Steam Management

#### Why ACF Anti-Update?

Infinity Nikki Steam CN version (AppID: **3164330**) uses `%command%` advanced launch to connect the CN launcher. Steam only launches the shell; core data is managed independently by the CN version.

**Problem**: After each official update, Steam detects a version mismatch and triggers a full ~110 GB download, but the core data is managed by the CN launcher — the Steam shell only needs version number sync.

**Solution**: Modify `appmanifest_3164330.acf` to make Steam think the local version is already up-to-date:

| ACF Field | Value | Purpose |
|-----------|-------|---------|
| `StateFlags` | `4` | Status: Installed & ready |
| `TargetBuildID` | `0` | Don't require update to a specific version |
| `buildid` | Latest from SteamDB | Match latest Public BuildID |
| `InstalledDepots` → `manifest` | Latest GID from SteamDB | Match Depot 3164332 latest manifest |
| `AutoUpdateBehavior` | `1` | Only check updates on launch |
| File read-only | ON | Prevent Steam from rewriting ACF |

#### Skeletonize Cleanup

In the Steam shell directory, `InfinityNikki\X6Game\` takes ~110 GB, but the game reads from the CN directory at runtime.

Skeletonize moves `X6Game` to a same-drive backup location (`{drive}\X6Game_backup`), freeing Steam directory space while keeping launcher-required files (`launcher.exe`, `steam_appid.txt`, etc.) intact. Steam can still launch the game normally.

> 💡 Moving is an NTFS same-drive operation — very fast, not a copy.

#### SteamDB Auto-Detect Flow

```
1.  Check if Steam is running → auto steam -shutdown if yes
2.  Read local ACF, extract current buildid and manifest GID
3.  Launch Google Chrome (--remote-debugging-port=9222)
    → Uses isolated Chrome Profile (doesn't interfere with your browser)
    → Auto-navigates to SteamDB depot page
4.  Inject JavaScript via Chrome CDP WebSocket to extract page data
5.  Parse latest Public buildid and Manifest GID via regex
6.  Compare with local version
    → Match: No action needed, report status
    → Mismatch: Backup ACF → Update fields → Lock read-only
7.  Sync SizeOnDisk to actual directory size
```

Auto-runs network diagnostics (Ping + DNS + Proxy check) when SteamDB access times out.

### Journal Monitoring

Access `https://myl.nuanpaper.com/tools/journal` via Chrome (`Cache\chrome_temp_profile\` dedicated profile) to:

| Feature | Description |
|---------|-------------|
| Stamina Monitor | Extract current stamina, calculate refill time with PowerShell `Get-Date` |
| Digging Progress | Extract digging progress, calculate completion time |
| Gacha Record Query | Supports nickname→official name mapping, exact/fuzzy queries |

> ⚠️ Gacha page doesn't show 3★ duplicate records, so pity data is unavailable. Results are confirmed record stats only.

### Exploration Progress Query

Access the **Exploration Overview** tab (2nd tab) of the Journal to extract regional exploration data:

| Dimension | Description |
|-----------|-------------|
| Warp Spires (Teleport Points) | Progress X/Y per region |
| Whimstars | World collectible progress X/Y |
| Inspiration Dews | World collectible progress X/Y |
| Sub-region Collectibles | Balloons/Crystals/Bubbles/Orbs/Jade items X/Y |

> **Data saving**: Each query auto-saves all exploration data to `{USER_DATA_DIR}nuan_explore.json`. Cache valid for 7 days, can be refreshed via scheduled tasks.

### Public Info Query

Retrieve public information from two different sources via Chrome (`Cache\chrome_temp_profile\`):

| Feature | Description |
|---------|-------------|
| Coupon Codes | Auto-fetch currently valid coupon code list, rewards, and expiry info |
| Recharge History | Query last 6 months of recharge order details, results persisted to file |

> **Recharge history persistence**: Each query result is automatically appended to `{USER_DATA_DIR}nuan_recharge_history.json` — append-only, never overwrite. Full traceability of past queries.

---

## Script Command Reference

All scripts execute from the skill root directory. The following is for direct PowerShell use — through the Agent, no manual typing needed.

### nuanskill-infi-manager.ps1

Steam full-feature manager (single file, zero external dependencies, built-in config):

```powershell
.\scripts\nuanskill-infi-manager.ps1 <command> [options]
```

| Command | Description |
|---------|-------------|
| `status` | Show ACF status, Steam running state, X6Game location, standalone launcher info |
| `steamdb-check` | Full auto: Launch Chrome → Scrape SteamDB → Compare → Update ACF → Lock read-only |
| `update` | Manual ACF update (requires `-BuildID` and `-ManifestGID`) |
| `skeletonize` | Move X6Game to same-drive backup, free space |
| `skeletonize -DryRun` | Preview skeletonize without execution |
| `restore` | Restore X6Game from backup to Steam directory |
| `lock` / `unlock` | Lock / Unlock ACF read-only attribute |
| `verify` | 7-point health check |
| `report` | Generate full status report |
| `residual-check` | Scan for residual files |
| `query` | Show SteamDB manual query links |

**Common Options**:

| Option | Description |
|--------|-------------|
| `-Force` | Skip confirmation prompts |
| `-DryRun` | Simulate without modifying files |
| `-BuildID <value>` | Manual BuildID (with `update` command) |
| `-ManifestGID <value>` | Manual Manifest GID (with `update` command) |

### nuanskill-gacha-lookup.ps1

Query outfit gacha stats (data source: `{USER_DATA_DIR}nuan_gacha_stats.json`):

```powershell
.\scripts\nuanskill-gacha-lookup.ps1 "Floral Poem"
.\scripts\nuanskill-gacha-lookup.ps1 --list
```

### nuanskill-time-calc.ps1

Stamina refill prediction + Digging completion time:

```powershell
.\scripts\nuanskill-time-calc.ps1 120        # Current stamina 120, calculate refill time
.\scripts\nuanskill-time-calc.ps1 --dig-all # Calculate all dig completion time
```

---

## Important Notes

| # | Note |
|---|------|
| 1 | **Must fully exit Steam** (including `steamwebhelper` process) before ACF operations |
| 2 | Read-only locked ACF prevents Steam from overwriting. Run `unlock` for normal updates |
| 3 | Steam → Game Properties → Updates → Set to **"Only update this game when I launch it"** |
| 4 | Script auto-creates `.bak` backups in `backups\` directory before modifying ACF |
| 5 | Skeletonize is a same-drive NTFS move, very fast, but won't cross drives |
| 6 | Re-run `steamdb-check` after each official update |
| 7 | Re-login to Journal when cookies expire, update `{USER_DATA_DIR}nuan_profile.json` |
| 8 | **First gacha crawl is slow**: 5-15 minutes to traverse all history. Data saved to `{USER_DATA_DIR}nuan_gacha_stats.json` afterwards — subsequent queries are instant |
| 9 | **First-time manual login required**: Agent opens visible Chrome for Journal login (captcha included), then auto-extracts cookies |
| 10 | **Scheduled task tip**: When creating auto-tasks (e.g., monthly gacha update), also update exploration data (`nuan_explore_data.json`) |
| 11 | `Cache/` and `user-data/` excluded from version control (in `.gitignore`) |

---

## FAQ

### Q: Does ACF anti-update trigger Steam anti-cheat?
A: No. It only modifies the local `appmanifest` file, affecting Steam client version detection — not game memory or network packets.

### Q: Does skeletonize delete my game data?
A: No. X6Game is **moved** to a same-drive backup location, restorable anytime via the `restore` command.

### Q: Why does it need Google Chrome?
A: SteamDB detection uses Chrome CDP (Chrome DevTools Protocol) to auto-scrape page data. Other Chromium-based browsers (Edge/Brave) are also supported by specifying the path in the script.

### Q: How long do Journal cookies last?
A: Typically 7-30 days, depending on the server policy. The Agent will prompt re-login when they expire.

### Q: Why does gacha query return "no results"?
A: Check if the outfit name is correct. The Agent auto-maps nicknames to official names, but very new outfits may not be recorded yet.

### Q: Why is the first gacha query slow?
A: The first crawl traverses all pull history pages, taking 5-15 minutes. Data is cached locally afterwards for instant queries.

### Q: Does exploration data expire?
A: Warp spires and collectibles don't change daily like stamina. Local cache is valid for ~7 days. The Agent auto-refreshes on each query.

### Q: Cross-platform support (Mac / Linux)?
A: Currently Windows 10/11 only, due to PowerShell and Windows path dependency.

### Q: Is this project open source?
A: No open-source license declared yet. Published as a public GitHub repository for learning and personal use. License TBD.

---

## Changelog

Full changelog available in `CHANGELOG.md`.

Current version: **v1.4.0 (2026-06-28)**.

---

## Reference Links

- [Infinity Nikki Official Website](https://infinitynikki.infoldgames.com/)
- [SteamDB — App 3164330](https://steamdb.info/app/3164330/)
- [SteamDB — Sub 1221922](https://steamdb.info/sub/1221922/)
- [SteamDB — Depot 3164332](https://steamdb.info/depot/3164332/manifests/)
- [ZhiXiang Notebook (Journal)](https://myl.nuanpaper.com/)
- [Technical Reference: Steam Update Mechanism & ACF Files](https://cloud.tencent.com/developer/article/2468980)
- [InfiSteam (Desktop version of this project)](https://github.com/qtqtEricChiu/InfiSteam)

---

## Related Projects

### [InfiSteam](https://github.com/qtqtEricChiu/InfiSteam)

Infinity Nikki Steam Advanced Launch Manager (Standalone Desktop App)

- WinUI 3 / WPF desktop + AI Agent prompts
- For users who prefer GUI over AI Agent interaction
- This skill's Steam management core logic originates from this project

### [InfiMouse](https://github.com/qtqtEricChiu/InfiMouse)

Gameplay Recording Assistant — Windows mouse trajectory control & synchronized input tool

- WinUI 3 + Bezier curve human-like mouse trajectory planning
- Keyboard event timeline sync + Xbox virtual controller injection
- Anti-detection humanization (jitter, speed variance, overshoot, random pauses)
- Suitable for gameplay recording and automation demo scenarios
- Tech stack: C# / WinUI 3 / MVVM / SendInput / XInput

---

<p align="center">
  <sub>
    This tool is not affiliated with <strong>Papergames</strong> / <strong>Infold Games</strong>, <strong>SteamDB</strong>, or <strong>Valve Corporation</strong>.<br />
    Infinity Nikki © 2024 Papergames, ALL RIGHTS RESERVED. Steam is a trademark of Valve Corporation.
  </sub>
</p>
