#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

if (-not $PSCmdlet.ShouldProcess('Windows', 'DISM RestoreHealth + sfc /scannow')) {
    Write-Log 'WhatIf: dism /Online /Cleanup-Image /RestoreHealth'
    Write-Log 'WhatIf: sfc /scannow'
    return
}

dism /Online /Cleanup-Image /RestoreHealth | Out-Null
$cod = $LASTEXITCODE
if ($cod -notin 0, 3010) { Write-Log "DISM RestoreHealth falhou (código $cod); sfc não executado." 'WARN'; return }
Write-Log "DISM RestoreHealth OK (código $cod)."

$tmp = [IO.Path]::GetTempFileName()
try {
    $p = Start-Process sfc -ArgumentList '/scannow' -Wait -NoNewWindow -PassThru -RedirectStandardOutput $tmp
    $txt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($tmp)) -replace "`0", ''
    $resumo = ($txt -split "`r?`n" | Where-Object { $_.Trim() -and $_ -notmatch '%' } | Select-Object -Last 3) -join ' | '
    if ($p.ExitCode -ne 0) { Write-Log "sfc código $($p.ExitCode): $resumo" 'WARN' } else { Write-Log "sfc: $resumo" }
} catch { Write-Log "sfc: $($_.Exception.Message)" 'WARN' }
finally { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
