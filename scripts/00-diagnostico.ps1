#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param([string]$Prefixo = 'antes', [switch]$SemEstado)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
$simul = $SemEstado -or [bool]$WhatIfPreference   # -SemEstado: simulação sem passar -WhatIf (WhatIf faz o autoload de módulos imprimir milhares de linhas)

function Get-TamanhoGB([string]$Caminho) {
    $total = [int64]0
    $pilha = New-Object Collections.Generic.Stack[string]
    $pilha.Push($Caminho)
    while ($pilha.Count) {
        $d = $pilha.Pop()
        try {
            $di = New-Object IO.DirectoryInfo $d
            foreach ($f in $di.EnumerateFiles()) { $total += $f.Length }
            foreach ($s in $di.EnumerateDirectories()) {
                if (-not ($s.Attributes -band [IO.FileAttributes]::ReparsePoint)) { $pilha.Push($s.FullName) }
            }
        } catch { }   # sem acesso: ignora
    }
    [math]::Round($total / 1GB, 2)
}

$md = New-Object Collections.Generic.List[string]
function Secao([string]$titulo, [scriptblock]$corpo) {
    $md.Add("## $titulo"); $md.Add('')
    try { $linhas = @(& $corpo); $md.Add('```'); foreach ($l in $linhas) { $md.Add([string]$l) }; $md.Add('```') }
    catch { $md.Add("Indisponível: $($_.Exception.Message)"); Write-Log "$titulo : $($_.Exception.Message)" 'WARN' }
    $md.Add('')
}

$livre = Get-FreeSpaceGB
$md.Add("# Diagnóstico ($Prefixo) - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"); $md.Add('')
Secao 'Espaço em C:' { "Livre: $livre GB" }
Secao 'Top 15 pastas em LOCALAPPDATA' {
    Get-ChildItem $env:LOCALAPPDATA -Directory -Force -ErrorAction SilentlyContinue |
        ForEach-Object { [pscustomobject]@{ GB = Get-TamanhoGB $_.FullName; Pasta = $_.Name } } |
        Sort-Object GB -Descending | Select-Object -First 15 | ForEach-Object { '{0,8} GB  {1}' -f $_.GB, $_.Pasta }
}
Secao 'Inicialização (Win32_StartupCommand)' {
    Get-CimInstance Win32_StartupCommand | ForEach-Object { "$($_.Name) | $($_.Location) | $($_.User) | $($_.Command)" }
}
Secao 'Apps provisionados' { (Get-AppxProvisionedPackage -Online).DisplayName | Sort-Object }
Secao 'Plano de energia' { powercfg /getactivescheme }
Secao 'Pontos de restauração' {
    Get-ComputerRestorePoint | ForEach-Object { "$($_.SequenceNumber) | $($_.CreationTime) | $($_.Description)" }
}
Secao 'Tamanhos de pastas do sistema' {
    "Temp usuário: $(Get-TamanhoGB $env:TEMP) GB"
    "Windows\Temp: $(Get-TamanhoGB 'C:\Windows\Temp') GB"
    "Lixeira: $(Get-TamanhoGB 'C:\$Recycle.Bin') GB"
    "WinSxS: $(Get-TamanhoGB 'C:\Windows\WinSxS') GB (inflado por hardlinks)"
    "SoftwareDistribution\Download: $(Get-TamanhoGB 'C:\Windows\SoftwareDistribution\Download') GB"
}

$dir = Join-Path $PSScriptRoot '..\relatorios'
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$arq = Join-Path $dir ('{0}-{1}.md' -f $Prefixo, (Get-Date -Format 'yyyyMMdd-HHmm'))
Set-Content -LiteralPath $arq -Value $md -Encoding UTF8
Write-Log "Relatório: $arq"

if ($Prefixo -eq 'antes') {
    if ($simul) { Write-Log 'WhatIf: EspacoInicialGB não gravado.' }
    elseif (Save-State -Id 'EspacoInicialGB' -Data @{ Tipo = 'Info'; Valor = $livre }) { Write-Log "Espaço inicial gravado: $livre GB" }
}
