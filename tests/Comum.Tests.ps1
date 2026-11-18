#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
$raiz = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $raiz 'lib\Comum.psm1') -Force

$script:falhas = 0
function Assert-True($cond, $nome) {
    if ($cond) { Write-Host "OK   $nome" } else { Write-Host "FALHA $nome" -ForegroundColor Red; $script:falhas++ }
}
function Lanca($sb) { try { & $sb; $false } catch { $true } }

$tmp = Join-Path $env:TEMP ('otimizar-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    # Save-State
    Set-StatePath (Join-Path $tmp 'estado.json')
    $a = Save-State -Id 'X' -Data @{ Valor = 1 }
    $b = Save-State -Id 'X' -Data @{ Valor = 2 }
    Assert-True ($a -and -not $b -and (Get-State -Id 'X').Data.Valor -eq 1) 'Save-State nao sobrescreve'
    Assert-True (@(Get-State).Count -eq 1) 'Get-State lista'

    # Remove-SafeItem
    $d = Join-Path $tmp 'lixo'; New-Item -ItemType Directory -Path "$d\sub" | Out-Null
    $velho = Join-Path $d 'sub\velho.txt'; $novo = Join-Path $d 'novo.txt'
    Set-Content $velho 'a'; Set-Content $novo 'b'
    (Get-Item $velho).LastWriteTime = (Get-Date).AddDays(-5)
    (Get-Item "$d\sub").LastWriteTime = (Get-Date).AddDays(-5)
    Remove-SafeItem -Path $d -OlderThanDays 1 -Recurse -WhatIf | Out-Null
    Assert-True (Test-Path $velho) 'Remove-SafeItem -WhatIf nao apaga'
    $r = Remove-SafeItem -Path $d -OlderThanDays 1 -Recurse
    Assert-True ((-not (Test-Path $velho)) -and (Test-Path $novo) -and $r.Removidos -eq 1) 'Remove-SafeItem apaga antigo e mantem novo'
    Assert-True (-not (Test-Path "$d\sub")) 'pasta vazia antiga removida'
    Assert-True (Lanca { Remove-SafeItem -Path 'C:\Program Files' -Recurse -WhatIf }) 'Remove-SafeItem recusa ancestral'
}
finally { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }

# config\ajustes.psd1: ids únicos e campos exigidos por tipo
$aj = (Import-PowerShellDataFile (Join-Path $raiz 'config\ajustes.psd1')).Ajustes
$campos = @{ Registro = 'Caminho', 'Nome', 'Valor', 'TipoValor'; StartupRemover = 'Caminho', 'Padrao'; Servico = 'Nome', 'Inicio'; Tarefa = 'Pasta', 'Nome'; App = 'Nome'; Energia = @(); BiosDell = 'Nome', 'Valor' }
$dup = $aj | Group-Object { $_.Id } | Where-Object Count -gt 1 | ForEach-Object Name
Assert-True (-not $dup) "ajustes: ids unicos $($dup -join ',')"
$inval = $aj | Where-Object { $x = $_; -not $campos.ContainsKey([string]$x.Tipo) -or ($campos[$x.Tipo] | Where-Object { -not $x.ContainsKey($_) }) } | ForEach-Object Id
Assert-True (-not $inval) "ajustes: tipo e campos validos $($inval -join ',')"
$svcInval = $aj | Where-Object { $_.Tipo -eq 'Servico' -and $_.Inicio -notin 'Disabled', 'Manual' } | ForEach-Object Id
Assert-True (-not $svcInval) "ajustes: Inicio de servico valido $($svcInval -join ',')"
# simulação completa não lança e não grava estado
$estadoReal = Join-Path $raiz 'estado\estado.json'
$antes = if (Test-Path $estadoReal) { (Get-FileHash $estadoReal).Hash }
$saida = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $raiz 'scripts\04-ajustes.ps1') -Maximo -WhatIf 2>&1 | Out-String
Assert-True ($LASTEXITCODE -eq 0 -and $saida -notmatch 'tipo desconhecido') '04-ajustes -Maximo -WhatIf roda sem erro'
Assert-True ($antes -eq $(if (Test-Path $estadoReal) { (Get-FileHash $estadoReal).Hash })) '04-ajustes -WhatIf nao grava estado'

# BOM
$ruins = Get-ChildItem $raiz -Recurse -Include *.ps1, *.psm1, *.psd1 -File | Where-Object { $_.FullName -notmatch '\\\.git\\' } | Where-Object {
    $b = [IO.File]::ReadAllBytes($_.FullName); -not ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF)
}
Assert-True (-not $ruins) ('BOM em todos os scripts ' + (($ruins | ForEach-Object Name) -join ','))

if ($script:falhas) { Write-Host "$script:falhas falha(s)" -ForegroundColor Red; exit 1 }
Write-Host 'Todos os testes passaram'; exit 0
