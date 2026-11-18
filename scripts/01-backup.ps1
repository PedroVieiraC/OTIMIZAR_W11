#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

$desc = 'OTIMIZAR_WINDOWS antes'
$freq = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
$nomeFreq = 'SystemRestorePointCreationFrequency'

if ($PSCmdlet.ShouldProcess('C:\', 'Enable-ComputerRestore + Checkpoint-Computer')) {
    Enable-ComputerRestore -Drive 'C:\'
    $antes = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | ForEach-Object SequenceNumber | Sort-Object)
    $maxAntes = if ($antes.Count) { $antes[-1] } else { -1 }
    $existia = $null -ne (Get-ItemProperty -LiteralPath $freq -Name $nomeFreq -ErrorAction SilentlyContinue)
    $orig = if ($existia) { (Get-ItemProperty -LiteralPath $freq).$nomeFreq }
    try {
        Set-ItemProperty -LiteralPath $freq -Name $nomeFreq -Value 0 -Type DWord
        Checkpoint-Computer -Description $desc -RestorePointType MODIFY_SETTINGS
    }
    finally {
        if ($existia) { Set-ItemProperty -LiteralPath $freq -Name $nomeFreq -Value $orig -Type DWord }
        else { Remove-ItemProperty -LiteralPath $freq -Name $nomeFreq -ErrorAction SilentlyContinue }
    }
    $achou = Get-ComputerRestorePoint | Where-Object { $_.Description -eq $desc -and $_.SequenceNumber -gt $maxAntes }
    if (-not $achou) { throw 'Ponto de restauração não encontrado após Checkpoint-Computer.' }
    Write-Log "Ponto de restauração criado (#$(@($achou)[-1].SequenceNumber))."
}

# reg export das chaves tocadas por 04-ajustes
$cfg = Import-PowerShellDataFile (Join-Path $PSScriptRoot '..\config\ajustes.psd1')
$chaves = $cfg.Ajustes | Where-Object { $_.Tipo -in 'Registro', 'StartupRemover' } | ForEach-Object { $_.Caminho } | Sort-Object -Unique
$n = 0
foreach ($c in $chaves) {
    $n++
    if (-not (Test-Path -LiteralPath $c)) { Write-Log "Chave ausente (nada a exportar): $c"; continue }
    $arq = Join-Path $PSScriptRoot "..\estado\reg-$n.reg"
    if ($PSCmdlet.ShouldProcess($c, "reg export para $arq")) {
        New-Item -ItemType Directory -Path (Split-Path $arq) -Force | Out-Null
        reg.exe export ($c -replace '^(HKLM|HKCU):\\', '$1\') $arq /y | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "reg export falhou ($LASTEXITCODE): $c" }
        Write-Log "Exportado: $c"
    }
}
