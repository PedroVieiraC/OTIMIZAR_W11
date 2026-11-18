#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

$wi = [bool]$WhatIfPreference
$script:totalGB = 0.0

function Limpar([string]$Categoria, [string]$Path, [int]$Dias, [switch]$Recurse) {
    try {
        $r = Remove-SafeItem -Path $Path -OlderThanDays $Dias -Recurse:$Recurse -WhatIf:$wi
        Registrar $Categoria $r
        $r
    } catch { Write-Log "$Categoria : $($_.Exception.Message)" 'WARN' }
}
function Registrar([string]$Categoria, $r) {
    $gb = [math]::Round(($r.Bytes + $r.BytesSim) / 1GB, 3)
    $script:totalGB += $gb
    $modo = if ($wi) { 'seriam liberados' } else { 'liberados' }
    Write-Log "$Categoria : $gb GB $modo (removidos $($r.Removidos), simulados $($r.Simulados), ignorados $($r.Ignorados))"
}

$antes = Get-FreeSpaceGB
Write-Log "Espaço livre antes: $antes GB"

$ocupado = (@(Get-Process msiexec -ErrorAction SilentlyContinue).Count -gt 1) -or [bool](Get-Process TiWorker -ErrorAction SilentlyContinue)
if ($ocupado) { Write-Log 'msiexec/TiWorker em execução: pulando Temp e SoftwareDistribution.' 'WARN' }
else {
    Limpar 'Temp do usuário' $env:TEMP 1 -Recurse | Out-Null
    Limpar 'Windows\Temp' 'C:\Windows\Temp' 1 -Recurse | Out-Null

    $nomes = 'wuauserv', 'bits'
    $rodando = @($nomes | Where-Object { (Get-Service $_ -ErrorAction SilentlyContinue).Status -eq 'Running' })
    try {
        if ($PSCmdlet.ShouldProcess(($rodando -join ','), 'Parar serviços')) {
            foreach ($s in $rodando) {
                Stop-Service $s -Force -ErrorAction Stop
                (Get-Service $s).WaitForStatus('Stopped', [TimeSpan]::FromSeconds(30))
            }
        }
        Limpar 'SoftwareDistribution\Download' 'C:\Windows\SoftwareDistribution\Download' 0 -Recurse | Out-Null
    } catch { Write-Log "SoftwareDistribution: $($_.Exception.Message)" 'WARN' }
    finally {
        if (-not $wi) { foreach ($s in $rodando) { Start-Service $s -ErrorAction SilentlyContinue } }
    }
}

# Delivery Optimization
if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
    if ($PSCmdlet.ShouldProcess('Delivery Optimization', 'Limpar cache')) {
        try { Delete-DeliveryOptimizationCache -Force; Write-Log 'Cache do Delivery Optimization limpo.' }
        catch { Write-Log "Delivery Optimization: $($_.Exception.Message)" 'WARN' }
    }
} else { Write-Log 'Delete-DeliveryOptimizationCache indisponível.' 'WARN' }

Limpar 'Miniaturas' (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer\thumbcache_*.db') 0 | Out-Null

# CBS: só *.log antigos, nunca o CBS.log ativo
try {
    $cbs = Get-ChildItem 'C:\Windows\Logs\CBS' -Filter '*.log' -File -Force -ErrorAction Stop | Where-Object { $_.Name -ne 'CBS.log' -and $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
    $r = [pscustomobject]@{ Removidos = 0; Ignorados = 0; Bytes = [int64]0; Simulados = 0; BytesSim = [int64]0 }
    foreach ($f in $cbs) {
        $x = Remove-SafeItem -Path $f.FullName -OlderThanDays 7 -WhatIf:$wi
        $r.Removidos += $x.Removidos; $r.Ignorados += $x.Ignorados; $r.Bytes += $x.Bytes; $r.Simulados += $x.Simulados; $r.BytesSim += $x.BytesSim
    }
    Registrar 'CBS logs' $r
} catch { Write-Log "CBS logs: $($_.Exception.Message)" 'WARN' }

Limpar 'WER ReportArchive' 'C:\ProgramData\Microsoft\Windows\WER\ReportArchive' 7 -Recurse | Out-Null
Limpar 'WER ReportQueue' 'C:\ProgramData\Microsoft\Windows\WER\ReportQueue' 7 -Recurse | Out-Null

# Lixeira > 30 dias (data de exclusão vem do arquivo $I)
$lix = [pscustomobject]@{ Removidos = 0; Ignorados = 0; Bytes = [int64]0; Simulados = 0; BytesSim = [int64]0 }
$limite = (Get-Date).AddDays(-30)
foreach ($sid in (Get-ChildItem 'C:\$Recycle.Bin' -Directory -Force -ErrorAction SilentlyContinue)) {
    foreach ($i in (Get-ChildItem -LiteralPath $sid.FullName -Filter '$I*' -File -Force -ErrorAction SilentlyContinue)) {
        try {
            $data = $i.LastWriteTime
            $b = [IO.File]::ReadAllBytes($i.FullName)
            if ($b.Length -ge 24 -and [BitConverter]::ToInt64($b, 0) -in 1, 2) { $data = [DateTime]::FromFileTime([BitConverter]::ToInt64($b, 16)) }
            if ($data -ge $limite) { continue }
            $rp = Join-Path $sid.FullName ('$R' + $i.Name.Substring(2))
            $ign = 0
            if (Test-Path -LiteralPath $rp) {
                $x = Remove-SafeItem -Path $rp -OlderThanDays 0 -Recurse -WhatIf:$wi
                $lix.Removidos += $x.Removidos; $lix.Bytes += $x.Bytes; $lix.Simulados += $x.Simulados; $lix.BytesSim += $x.BytesSim; $ign = $x.Ignorados
                $lix.Ignorados += $ign
                if (-not $wi -and -not $ign -and (Test-Path -LiteralPath $rp -PathType Container)) {
                    Remove-Item -LiteralPath $rp -Force -ErrorAction SilentlyContinue   # raiz vazia
                }
            }
            if (-not $ign) { Remove-SafeItem -Path $i.FullName -OlderThanDays 0 -WhatIf:$wi | Out-Null }
        } catch { $lix.Ignorados++ }   # acesso negado etc.
    }
}
Registrar 'Lixeira >30 dias' $lix

# caches de desenvolvimento
foreach ($c in @(@{ N = 'npm'; A = @('cache', 'clean', '--force') }, @{ N = 'pip'; A = @('cache', 'purge') })) {
    if (-not (Get-Command $c.N -ErrorAction SilentlyContinue)) { continue }
    if ($PSCmdlet.ShouldProcess($c.N, 'Limpar cache')) {
        # PS 5.1 com 'Stop' transforma qualquer linha de stderr (ex.: aviso do npm) em erro fatal
        $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        try { & $c.N @($c.A) 2>&1 | Out-Null } finally { $ErrorActionPreference = $eap }
        if ($LASTEXITCODE -ne 0) { Write-Log "$($c.N) cache: código $LASTEXITCODE" 'WARN' } else { Write-Log "Cache $($c.N) limpo." }
    }
}

# componentes do Windows (sem /ResetBase)
if ($PSCmdlet.ShouldProcess('Windows', 'dism /StartComponentCleanup')) {
    dism /Online /Cleanup-Image /StartComponentCleanup | Out-Null
    if ($LASTEXITCODE -notin 0, 3010) { Write-Log "DISM StartComponentCleanup: código $LASTEXITCODE" 'WARN' } else { Write-Log 'DISM StartComponentCleanup concluído.' }
} else { Write-Log 'WhatIf: dism /Online /Cleanup-Image /StartComponentCleanup' }

$depois = Get-FreeSpaceGB
Write-Log ("Total estimado por categorias: {0} GB | Espaço livre depois: {1} GB (diferença {2} GB)" -f [math]::Round($script:totalGB, 2), $depois, [math]::Round($depois - $antes, 2))
