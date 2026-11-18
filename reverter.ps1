#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param([string[]]$Id)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

$itens = @(Get-State) | Where-Object { $_.Data.Tipo -in 'Registro', 'Startup', 'Servico', 'Tarefa', 'App', 'Energia', 'BiosDell' -and (-not $Id -or $_.Id -in $Id) }
if (-not $itens) { Write-Log 'Nada a reverter.'; return }
foreach ($e in $itens) {
    $d = $e.Data
    try {
        if ($d.Tipo -eq 'Servico') {
            if ($PSCmdlet.ShouldProcess($d.Nome, "Restaurar inicialização '$($d.Inicio)'")) {
                Set-Service -Name $d.Nome -StartupType $d.Inicio
                Write-Log "$($e.Id): restaurado ($($d.Inicio)); volta a rodar no próximo boot"
            }
        }
        elseif ($d.Tipo -eq 'Tarefa') {
            if ($PSCmdlet.ShouldProcess("$($d.Pasta)$($d.Nome)", 'Reativar tarefa agendada')) {
                Enable-ScheduledTask -TaskPath $d.Pasta -TaskName $d.Nome | Out-Null
                Write-Log "$($e.Id): reativada"
            }
        }
        elseif ($d.Tipo -eq 'App') {
            if ($PSCmdlet.ShouldProcess($d.Nome, 'Re-registrar app')) {
                $p = Get-AppxPackage -AllUsers -Name $d.Nome | Select-Object -First 1
                if ($p -and (Test-Path -LiteralPath "$($p.InstallLocation)\AppxManifest.xml")) {
                    Add-AppxPackage -Register "$($p.InstallLocation)\AppxManifest.xml" -DisableDevelopmentMode
                    Write-Log "$($e.Id): re-registrado"
                }
                else { Write-Log "$($e.Id): pacote não está mais no sistema; reinstale '$($d.Nome)' pela Microsoft Store" 'WARN' }
            }
        }
        elseif ($d.Tipo -eq 'Energia') {
            if ($PSCmdlet.ShouldProcess('powercfg', "Restaurar plano $($d.Plano) e modo $($d.Overlay)")) {
                cmd /c "powercfg /setactive $($d.Plano) >nul 2>&1"
                if ($d.Overlay) { cmd /c "powercfg /overlaysetactive $($d.Overlay) >nul 2>&1" }
                Write-Log "$($e.Id): restaurado"
            }
        }
        elseif ($d.Tipo -eq 'BiosDell') {
            if ($PSCmdlet.ShouldProcess("BIOS $($d.Nome)", "Restaurar '$($d.Valor)'")) {
                $r = (Get-WmiObject -Namespace 'root\dcim\sysman\biosattributes' -Class BIOSAttributeInterface).SetAttribute(0, 0, 0, $d.Nome, $d.Valor)
                if ($r.Status -ne 0) { Write-Log "$($e.Id): BIOS recusou (status $($r.Status))" 'WARN' } else { Write-Log "$($e.Id): restaurado, vale após reiniciar" }
            }
        }
        elseif ($d.Tipo -eq 'Registro' -and -not $d.Existia) {
            if ($PSCmdlet.ShouldProcess("$($d.Caminho)\$($d.Nome)", 'Remover valor (não existia antes)')) {
                Remove-ItemProperty -LiteralPath $d.Caminho -Name $d.Nome -ErrorAction SilentlyContinue
                Write-Log "$($e.Id): removido"
            }
        }
        elseif ($PSCmdlet.ShouldProcess("$($d.Caminho)\$($d.Nome)", "Restaurar valor original '$($d.Valor)' ($($d.TipoValor))")) {
            if (-not (Test-Path -LiteralPath $d.Caminho)) { New-Item -Path $d.Caminho -Force | Out-Null }
            New-ItemProperty -LiteralPath $d.Caminho -Name $d.Nome -Value $d.Valor -PropertyType $d.TipoValor -Force | Out-Null
            Write-Log "$($e.Id): restaurado"
        }
    } catch { Write-Log "$($e.Id): $($_.Exception.Message)" 'WARN' }
}
