#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidatePattern('^[0-5]+$')][string]$Etapas = '012345',   # ex.: -Etapas 0145 pula limpeza (2) e reparo (3, que leva horas)
    [switch]$Maximo                                            # repassado ao 04-ajustes
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

$extra = @{}
if ($WhatIfPreference) { $extra.WhatIf = $true }
foreach ($s in (Get-ChildItem (Join-Path $PSScriptRoot 'scripts') -File | Where-Object { $_.Name -like '0[0-5]-*.ps1' -and $Etapas.Contains($_.Name.Substring(1, 1)) } | Sort-Object Name)) {
    Write-Log "== $($s.Name) =="
    try {
        if ($WhatIfPreference -and $s.Name -like '00-*') { & $s.FullName -SemEstado -WhatIf:$false }
        elseif ($s.Name -like '04-*') { & $s.FullName @extra -Maximo:$Maximo }
        else { & $s.FullName @extra }
    }
    catch {
        Write-Log "Falha em $($s.Name): $($_.Exception.Message). Execução interrompida." 'ERRO'
        exit 1   # inclui 01-backup: sem backup, não segue
    }
}
Write-Log 'Concluído.'
