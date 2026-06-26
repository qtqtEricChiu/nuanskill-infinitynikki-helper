<#
.SYNOPSIS
    从 nuan_gacha_stats.json 按套装名称（正式名或关键词）查询抽卡数据。

.DESCRIPTION
    读取 user-data/nuan_gacha_stats.json，支持精确匹配和模糊匹配。
    模糊匹配返回所有名称或 category 中包含关键词的套装。

.PARAMETER Name
    套装名称或关键词。支持部分匹配（-Fuzzy 模式）和精确匹配（默认）。

.PARAMETER Fuzzy
    启用模糊匹配。不传则精确匹配 suit_name。

.PARAMETER Rarity
    限定星级：5 或 4。不传则搜索全部。

.PARAMETER ListAll
    列出所有套装的简要信息（名称 + 星级 + 总计共鸣）。

.EXAMPLE
    .\nuanskill-gacha-lookup.ps1 -Name "梦是心之涟"
    精确查询套装"梦是心之涟"。

.EXAMPLE
    .\nuanskill-gacha-lookup.ps1 -Name "花" -Fuzzy
    模糊搜索所有名称含"花"的套装。

.EXAMPLE
    .\nuanskill-gacha-lookup.ps1 -Name "心之涟" -Fuzzy -Rarity 5
    模糊搜索名称含"心之涟"的五星套装。

.EXAMPLE
    .\nuanskill-gacha-lookup.ps1 -ListAll
    列出全部 100 个套装的简要信息。
#>

param(
    [string]$Name,
    [switch]$Fuzzy,
    [ValidateSet(5, 4)]
    [int]$Rarity,
    [switch]$ListAll
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = Split-Path -Parent $ScriptDir
$jsonPath = Join-Path $SkillRoot "user-data\nuan_gacha_stats.json"

if (-not (Test-Path $jsonPath)) {
    Write-Error "数据文件不存在: $jsonPath"
    exit 1
}

$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

# 合并五星和四星数组
$allSuits = @()
if ($data.five_star_suits) { $allSuits += $data.five_star_suits }
if ($data.four_star_suits) { $allSuits += $data.four_star_suits }
# 兼容旧格式 suits 数组
if ($data.suits) { $allSuits += $data.suits }

if ($allSuits.Count -eq 0) {
    Write-Error "JSON 中未找到套装数据（five_star_suits / four_star_suits / suits 均为空）"
    exit 1
}

# 按星级过滤
if ($Rarity) {
    $allSuits = $allSuits | Where-Object { $_.rarity -eq $Rarity }
}

# 列出全部
if ($ListAll) {
    $allSuits | Sort-Object rarity, suit_name | Format-Table -AutoSize `
        @{Label="星级"; Expression={$_.rarity}},
        @{Label="套装名"; Expression={$_.suit_name}},
        @{Label="平均共鸣"; Expression={$_.avg_resonance}},
        @{Label="总计共鸣"; Expression={$_.total_resonance}},
        @{Label="部件数"; Expression={$_.parts_count}},
        @{Label="分类"; Expression={$_.category}}
    exit 0
}

if (-not $Name) {
    Write-Host "用法: .\nuanskill-gacha-lookup.ps1 -Name <套装名> [-Fuzzy] [-Rarity 5|4]"
    Write-Host "      .\nuanskill-gacha-lookup.ps1 -ListAll"
    exit 0
}

# 搜索
if ($Fuzzy) {
    $results = $allSuits | Where-Object {
        ($_.suit_name -like "*$Name*") -or ($_.category -like "*$Name*")
    }
} else {
    $results = $allSuits | Where-Object { $_.suit_name -eq $Name }
}

if ($results.Count -eq 0) {
    Write-Host "未找到匹配的套装。" -ForegroundColor Yellow
    if (-not $Fuzzy) {
        Write-Host "提示: 尝试使用 -Fuzzy 参数进行模糊搜索。" -ForegroundColor Gray
    }
    exit 0
}

Write-Host "找到 $($results.Count) 个匹配套装:" -ForegroundColor Green
Write-Host ""

$results | Sort-Object rarity, suit_name | ForEach-Object {
    $s = $_
    $starSymbol = if ($s.rarity -eq 5) { "★5" } else { "★4" }
    Write-Host "----------------------------------------"
    Write-Host "  $starSymbol  $($s.suit_name)"
    Write-Host "  分类:     $($s.category)"
    Write-Host "  总部件:   $($s.parts_count)"
    Write-Host "  平均共鸣: $($s.avg_resonance)"
    Write-Host "  总计共鸣: $($s.total_resonance)"
    Write-Host ""
}
