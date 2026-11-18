#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

try {
    $disco = Get-Partition -DriveLetter C | Get-Disk | Get-PhysicalDisk
    if ($disco.MediaType -eq 'SSD') {
        if ($PSCmdlet.ShouldProcess('C:', 'Optimize-Volume -ReTrim')) { Optimize-Volume -DriveLetter C -ReTrim; Write-Log 'TRIM concluído.' }
    } else { Write-Log "Disco C: não é SSD ($($disco.MediaType)); sem TRIM." }
} catch { Write-Log "TRIM: $($_.Exception.Message)" 'WARN' }

try { & (Join-Path $PSScriptRoot '00-diagnostico.ps1') -Prefixo 'depois' -SemEstado:$WhatIfPreference -WhatIf:$false }
catch { Write-Log "Diagnóstico final: $($_.Exception.Message)" 'WARN' }

$atual = Get-FreeSpaceGB
$ini = Get-State -Id 'EspacoInicialGB'
$linhas = New-Object Collections.Generic.List[string]
$linhas.Add("# Resumo - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"); $linhas.Add('')
if ($ini) {
    $lib = [math]::Round($atual - [double]$ini.Data.Valor, 2)
    $linhas.Add("- Espaço livre inicial: $($ini.Data.Valor) GB"); $linhas.Add("- Espaço livre atual: $atual GB"); $linhas.Add("- GB liberados: $lib")
    if ($lib -lt 15) { $linhas.Add('- Menos de 15 GB liberados: o escopo da limpeza é conservador (sem navegadores, Downloads, Documentos, /ResetBase, C:\Windows\Installer) e o sistema já estava relativamente limpo.') }
} else { $linhas.Add("- Espaço livre atual: $atual GB (espaço inicial não registrado)") }
$linhas.Add(''); $linhas.Add('## Ajustes aplicados (Ids no estado)')
foreach ($e in (@(Get-State) | Where-Object { $_.Data.Tipo -in 'Registro', 'Startup' })) { $linhas.Add("- $($e.Id)") }
$linhas.Add(''); $linhas.Add('## Avisos')
$linhas.Add('- Telemetria definida por política: Configurações mostrará "gerenciado pela organização".')
$linhas.Add('- Desfazer ajustes: reverter.ps1')
$arq = Join-Path $PSScriptRoot ('..\relatorios\resumo-{0}.md' -f (Get-Date -Format 'yyyyMMdd'))
if ($PSCmdlet.ShouldProcess($arq, 'Gravar resumo')) { Set-Content -LiteralPath $arq -Value $linhas -Encoding UTF8; Write-Log "Resumo: $arq" }
else { $linhas | Where-Object { $_ } | ForEach-Object { Write-Log $_ } }
