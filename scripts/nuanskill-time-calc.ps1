<#
.SYNOPSIS
    奇想手账时间计算工具 — 体力回满预测 + 美鸭梨挖掘完成时间推算。

.DESCRIPTION
    支持两种模式：
    1. 体力模式：输入当前体力值，输出预计满体力时间。
    2. 挖掘模式：输入倒计时文本（如 "2小时30分钟"），输出预计完成时间。
    所有时间计算基于 Get-Date 系统当前时间。

.PARAMETER Stamina
    模式一：当前体力值（0-350）。计算缺口并推算满体力时间。

.PARAMETER Excavation
    模式二：美鸭梨挖掘倒计时文本。支持 "X小时Y分钟" / "X小时" / "Y分钟" 格式。

.PARAMETER StaminaCap
    体力上限，默认 350。

.PARAMETER RegenMinutes
    每点体力恢复所需分钟数，默认 5。

.EXAMPLE
    .\nuanskill-time-calc.ps1 -Stamina 197
    当前体力 197，输出缺口和预计满体力时间。

.EXAMPLE
    .\nuanskill-time-calc.ps1 -Excavation "2小时30分钟"
    倒计时 2.5 小时后完成，输出预计完成的具体日期时间。

.EXAMPLE
    .\nuanskill-time-calc.ps1 -Excavation "45分钟"
    倒计时 45 分钟后完成。
#>

param(
    [ValidateRange(0, 999)]
    [int]$Stamina,
    [string]$Excavation,
    [int]$StaminaCap = 350,
    [int]$RegenMinutes = 5
)

$now = Get-Date
Write-Host "当前系统时间: $($now.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
Write-Host ""

# 模式一：体力回满预测
if ($PSBoundParameters.ContainsKey("Stamina")) {
    $gap = $StaminaCap - $Stamina
    $minutesLeft = $gap * $RegenMinutes
    $fullTime = $now.AddMinutes($minutesLeft)
    $hoursPart = [math]::Floor($minutesLeft / 60)
    $minsPart = $minutesLeft % 60

    Write-Host "========== 体力回满预测 =========="
    Write-Host "  当前体力: $Stamina / $StaminaCap"
    Write-Host "  缺口点数: $gap"
    Write-Host "  恢复时间: ${hoursPart}小时${minsPart}分钟 (共 ${minutesLeft} 分钟)"
    Write-Host "  预计满格: $($fullTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Host ""

    if ($Stamina -ge $StaminaCap) {
        Write-Host "  体力已满！" -ForegroundColor Green
    } elseif ($Stamina -ge 344) {
        Write-Host "  即将满体力（≤30分钟），请及时清体力！" -ForegroundColor Yellow
    }

    # 输出汇报格式模板
    Write-Host ""
    Write-Host "--- 汇报模板 ---" -ForegroundColor Gray
    Write-Host "【奇想手账体力提醒】当前体力 ${Stamina}/$StaminaCap，缺口 ${gap} 点，预计 $($fullTime.ToString('yyyy-MM-dd HH:mm:ss')) 恢复满格。请在 $($fullTime.ToString('HH:mm')) 前清体力～"
}

# 模式二：美鸭梨挖掘完成时间
if ($Excavation) {
    $totalMinutes = 0
    $input = $Excavation.Trim()

    # 解析 "X小时Y分钟" / "X小时" / "Y分钟"
    if ($input -match '(\d+)\s*小时\s*(\d+)\s*分钟') {
        $totalMinutes = [int]$Matches[1] * 60 + [int]$Matches[2]
    } elseif ($input -match '(\d+)\s*小时') {
        $totalMinutes = [int]$Matches[1] * 60
    } elseif ($input -match '(\d+)\s*分钟') {
        $totalMinutes = [int]$Matches[1]
    } else {
        Write-Error "无法解析倒计时文本: '$Excavation'。支持格式: 'X小时Y分钟' / 'X小时' / 'Y分钟'"
        exit 1
    }

    $completeTime = $now.AddMinutes($totalMinutes)
    $hoursPart = [math]::Floor($totalMinutes / 60)
    $minsPart = $totalMinutes % 60

    Write-Host "========== 美鸭梨挖掘完成预测 =========="
    if ($hoursPart -gt 0 -and $minsPart -gt 0) {
        Write-Host "  剩余时间: ${hoursPart}小时${minsPart}分钟"
    } elseif ($hoursPart -gt 0) {
        Write-Host "  剩余时间: ${hoursPart}小时"
    } else {
        Write-Host "  剩余时间: ${minsPart}分钟"
    }
    Write-Host "  预计完成: $($completeTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Host ""
    Write-Host "--- 汇报模板 ---" -ForegroundColor Gray
    Write-Host "预计完成时间: $($completeTime.ToString('yyyy-MM-dd HH:mm:ss'))"
}
