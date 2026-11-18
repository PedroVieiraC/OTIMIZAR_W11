#Requires -Version 5.1
# Utilitários compartilhados. Não aplica ajustes.

$script:Raiz = Split-Path $PSScriptRoot -Parent
$script:CaminhoEstado = Join-Path $script:Raiz 'estado\estado.json'

# Raízes do sistema: o item em si nunca é apagado, nem "tudo dentro dele" (curinga direto na raiz).
# Subpastas e arquivos dentro delas podem ser apagados (ex.: Windows\Temp).
$script:Raizes = @('C:', 'C:\Windows', 'C:\Windows\System32', 'C:\Program Files', 'C:\Program Files (x86)', 'C:\ProgramData', 'C:\Users')

function Assert-NotProtectedPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    $p = [IO.Path]::GetFullPath(($Path -replace '[*?]', '_')).TrimEnd('\')   # GetFullPath não aceita curingas
    $c = [StringComparison]::OrdinalIgnoreCase
    $pai = Split-Path $p -Parent
    if ($pai) { $pai = $pai.TrimEnd('\') }
    foreach ($r in $script:Raizes) {
        $esvaziaRaiz = ($Path -match '[*?]') -and $pai -and $pai.Equals($r, $c) -and ((Split-Path $Path -Leaf) -match '^[*?]+$')
        if ($p.Equals($r, $c) -or $esvaziaRaiz) { throw "Caminho protegido: $Path" }
    }
}

function Assert-Admin {
    [CmdletBinding()]
    param([switch]$Simulacao)
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { return }
    if ($Simulacao) { Write-Log 'Sem privilégio de administrador (aceito só em simulação -WhatIf).' 'WARN'; return }
    throw 'Execute em um PowerShell elevado (Administrador).'
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Message,
        [Parameter(Position = 1)][ValidateSet('INFO', 'WARN', 'ERRO')][string]$Level = 'INFO'
    )
    $origem = Get-PSCallStack | Where-Object { $_.ScriptName -and $_.ScriptName -ne $PSCommandPath } | Select-Object -First 1
    $nome = if ($origem) { [IO.Path]::GetFileNameWithoutExtension($origem.ScriptName) } else { 'comum' }
    $dir = Join-Path $script:Raiz 'logs'
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $linha = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    $cor = @{ INFO = 'Gray'; WARN = 'Yellow'; ERRO = 'Red' }[$Level]
    Write-Host $linha -ForegroundColor $cor
    [IO.File]::AppendAllText((Join-Path $dir ('{0}-{1}.log' -f $nome, (Get-Date -Format 'yyyyMMdd'))), $linha + "`r`n", (New-Object Text.UTF8Encoding $false))
}

function Set-StatePath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    $script:CaminhoEstado = $Path   # usado pelos testes
}

function Get-State {
    [CmdletBinding()]
    param([string]$Id)
    if (-not (Test-Path -LiteralPath $script:CaminhoEstado)) { if ($Id) { return $null } else { return @() } }
    $todos = @(Get-Content -LiteralPath $script:CaminhoEstado -Raw -Encoding UTF8 | ConvertFrom-Json)
    if ($Id) { return $todos | Where-Object { $_.Id -eq $Id } | Select-Object -First 1 }
    $todos
}

function Save-State {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][hashtable]$Data)
    if (Get-State -Id $Id) { return $false }   # preserva o valor original
    $lista = @(Get-State) + [pscustomobject]@{ Id = $Id; Quando = (Get-Date -Format 's'); Data = $Data }
    $dir = Split-Path $script:CaminhoEstado -Parent
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $tmp = $script:CaminhoEstado + '.tmp'
    [IO.File]::WriteAllText($tmp, (ConvertTo-Json -InputObject @($lista) -Depth 6), (New-Object Text.UTF8Encoding $false))
    Move-Item -LiteralPath $tmp -Destination $script:CaminhoEstado -Force
    $true
}

function Get-FreeSpaceGB {
    [CmdletBinding()]
    param([string]$Drive = 'C')
    [math]::Round(([IO.DriveInfo]($Drive.Substring(0, 1) + ':\')).AvailableFreeSpace / 1GB, 2)
}

function Remove-SafeItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Path,
        [int]$OlderThanDays = 0,
        [switch]$Recurse
    )
    Assert-NotProtectedPath $Path
    $corte = (Get-Date).AddDays(-$OlderThanDays)
    $r = [pscustomobject]@{ Removidos = 0; Ignorados = 0; Bytes = [int64]0; Simulados = 0; BytesSim = [int64]0 }
    $dirs = New-Object Collections.Generic.List[string]
    $mtimes = @{}   # mtime lido antes de apagar (apagar arquivos atualiza a pasta)
    $arquivos = New-Object Collections.Generic.List[IO.FileInfo]

    function Coletar($d) {
        foreach ($i in (Get-ChildItem -LiteralPath $d -Force -ErrorAction SilentlyContinue)) {
            if ($i.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            if ($i.PSIsContainer) { if ($Recurse) { $dirs.Add($i.FullName); $mtimes[$i.FullName] = $i.LastWriteTime; Coletar $i.FullName } }
            else { $arquivos.Add($i) }
        }
    }

    $raizes = if ($Path -match '[*?]') { Get-Item -Path $Path -Force -ErrorAction SilentlyContinue } else { Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue }
    foreach ($x in @($raizes)) {
        if ($x.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        if ($x.PSIsContainer) { Coletar $x.FullName } else { $arquivos.Add($x) }
    }

    $simulando = -not $PSCmdlet.ShouldProcess($Path, "Remover itens com mais de $OlderThanDays dia(s)")   # um aviso só, não um por arquivo
    foreach ($f in $arquivos) {
        if ($f.LastWriteTime -ge $corte) { continue }
        if ($simulando) { $r.Simulados++; $r.BytesSim += $f.Length; continue }
        try { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $r.Removidos++; $r.Bytes += $f.Length }
        catch { $r.Ignorados++ }   # em uso / sem acesso
    }
    # pastas vazias e antigas, de baixo para cima; nunca a raiz
    foreach ($d in ($dirs | Sort-Object Length -Descending)) {
        if ($mtimes[$d] -ge $corte -or @(Get-ChildItem -LiteralPath $d -Force -ErrorAction SilentlyContinue).Count) { continue }
        if (-not $simulando) { Remove-Item -LiteralPath $d -Force -ErrorAction SilentlyContinue }
    }
    $r
}

Export-ModuleMember -Function Assert-Admin, Assert-NotProtectedPath, Write-Log, Set-StatePath, Get-State, Save-State, Get-FreeSpaceGB, Remove-SafeItem
