#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param([switch]$Maximo)   # inclui os ajustes marcados Maximo = $true (têm perda de função; ver Descricao)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\lib\Comum.psm1') -Force
Assert-Admin -Simulacao:$WhatIfPreference

# carrega os módulos fora do modo simulação; senão o carregamento automático polui a saída do -WhatIf
$wi = $WhatIfPreference; $WhatIfPreference = $false
Import-Module Appx, CimCmdlets, ScheduledTasks
$WhatIfPreference = $wi
$cfg = Import-PowerShellDataFile (Join-Path $PSScriptRoot '..\config\ajustes.psd1')
foreach ($a in $cfg.Ajustes) {
    if ($a.Maximo -and -not $Maximo) { continue }
    try {
        if ($a.Tipo -eq 'Registro') {
            $existe = $false; $atual = $null; $tipoAtual = $null
            if (Test-Path -LiteralPath $a.Caminho) {
                $k = Get-Item -LiteralPath $a.Caminho
                if ($k.GetValueNames() -contains $a.Nome) { $existe = $true; $atual = $k.GetValue($a.Nome); $tipoAtual = [string]$k.GetValueKind($a.Nome) }
            }
            if ($existe -and $atual -eq $a.Valor -and $tipoAtual -eq $a.TipoValor) { Write-Log "$($a.Id): já aplicado"; continue }
            if (-not $PSCmdlet.ShouldProcess("$($a.Caminho)\$($a.Nome)", "Definir $($a.Valor)")) { continue }
            Save-State -Id $a.Id -Data @{ Tipo = 'Registro'; Caminho = $a.Caminho; Nome = $a.Nome; Existia = $existe; Valor = $atual; TipoValor = $tipoAtual } | Out-Null
            if (-not (Test-Path -LiteralPath $a.Caminho)) { New-Item -Path $a.Caminho -Force | Out-Null }
            New-ItemProperty -LiteralPath $a.Caminho -Name $a.Nome -Value $a.Valor -PropertyType $a.TipoValor -Force | Out-Null
            if ((Get-ItemProperty -LiteralPath $a.Caminho).($a.Nome) -ne $a.Valor) { Write-Log "$($a.Id): valor divergente após aplicar" 'WARN' }
            else { Write-Log "$($a.Id): aplicado. $($a.Descricao)" }
        }
        elseif ($a.Tipo -eq 'StartupRemover') {
            $achou = $false
            if (Test-Path -LiteralPath $a.Caminho) {
                $k = Get-Item -LiteralPath $a.Caminho
                foreach ($n in ($k.GetValueNames() | Where-Object { $_ -like $a.Padrao })) {
                    $achou = $true
                    if (-not $PSCmdlet.ShouldProcess("$($a.Caminho)\$n", 'Remover valor de inicialização')) { continue }
                    Save-State -Id "Startup:$n" -Data @{ Tipo = 'Startup'; Caminho = $a.Caminho; Nome = $n; Valor = $k.GetValue($n); TipoValor = [string]$k.GetValueKind($n) } | Out-Null
                    Remove-ItemProperty -LiteralPath $a.Caminho -Name $n
                    Write-Log "$($a.Id): removido '$n'"
                }
            }
            if (-not $achou) { Write-Log "$($a.Id): não encontrado ($($a.Padrao))" }
        }
        elseif ($a.Tipo -eq 'Servico') {
            $svc = Get-Service -Name $a.Nome -ErrorAction SilentlyContinue
            if (-not $svc) { Write-Log "$($a.Id): serviço '$($a.Nome)' não existe neste PC"; continue }
            if ([string]$svc.StartType -eq $a.Inicio) { Write-Log "$($a.Id): já aplicado"; continue }
            if (-not $PSCmdlet.ShouldProcess($a.Nome, "Inicialização $($svc.StartType) -> $($a.Inicio)")) { continue }
            # shortcut: "Automático (atraso)" é salvo como Automatic; ao reverter volta sem o atraso. Salvar DelayedAutostart se isso importar.
            Save-State -Id $a.Id -Data @{ Tipo = 'Servico'; Nome = $a.Nome; Inicio = [string]$svc.StartType } | Out-Null
            Set-Service -Name $a.Nome -StartupType $a.Inicio
            if ($a.Inicio -eq 'Disabled') { Stop-Service -Name $a.Nome -Force -ErrorAction SilentlyContinue }
            Write-Log "$($a.Id): $($a.Inicio). $($a.Descricao)"
        }
        elseif ($a.Tipo -eq 'Tarefa') {
            $t = Get-ScheduledTask -TaskPath $a.Pasta -TaskName $a.Nome -ErrorAction SilentlyContinue
            if (-not $t) { Write-Log "$($a.Id): tarefa não existe neste PC"; continue }
            if ($t.State -eq 'Disabled') { Write-Log "$($a.Id): já aplicado"; continue }
            if (-not $PSCmdlet.ShouldProcess("$($a.Pasta)$($a.Nome)", 'Desativar tarefa agendada')) { continue }
            Save-State -Id $a.Id -Data @{ Tipo = 'Tarefa'; Pasta = $a.Pasta; Nome = $a.Nome } | Out-Null
            $t | Disable-ScheduledTask | Out-Null
            Write-Log "$($a.Id): desativada. $($a.Descricao)"
        }
        elseif ($a.Tipo -eq 'App') {
            $p = Get-AppxPackage -Name $a.Nome
            if (-not $p) { Write-Log "$($a.Id): não instalado"; continue }
            if (-not $PSCmdlet.ShouldProcess($a.Nome, 'Remover app do usuário atual')) { continue }
            # shortcut: remove só do usuário atual (o pacote fica no sistema e o reverter consegue re-registrar);
            # usuários novos ainda recebem o app. Remover o provisionamento se isso incomodar.
            Save-State -Id $a.Id -Data @{ Tipo = 'App'; Nome = $a.Nome } | Out-Null
            $p | Remove-AppxPackage
            Write-Log "$($a.Id): removido. $($a.Descricao)"
        }
        elseif ($a.Tipo -eq 'Energia') {
            $melhor = 'ded574b5-45a0-4f42-8737-46345c09c238'   # overlay "Melhor desempenho"
            $ps = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
            if ($ps.ActiveOverlayAcPowerScheme -eq $melhor -or $ps.ActivePowerScheme -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') { Write-Log "$($a.Id): já aplicado"; continue }
            if (-not $PSCmdlet.ShouldProcess('powercfg', 'Modo de energia: Melhor desempenho')) { continue }
            Save-State -Id $a.Id -Data @{ Tipo = 'Energia'; Plano = $ps.ActivePowerScheme; Overlay = $ps.ActiveOverlayAcPowerScheme } | Out-Null
            cmd /c "powercfg /overlaysetactive $melhor >nul 2>&1"
            if ($LASTEXITCODE -ne 0) { cmd /c 'powercfg /setactive SCHEME_MIN >nul 2>&1' }   # PCs sem modos de energia: plano Alto desempenho
            if ($LASTEXITCODE -ne 0) { Write-Log "$($a.Id): powercfg falhou ($LASTEXITCODE)" 'WARN' } else { Write-Log "$($a.Id): aplicado. $($a.Descricao)" }
        }
        elseif ($a.Tipo -eq 'BiosDell') {
            $ns = 'root\dcim\sysman\biosattributes'
            $attr = Get-CimInstance -Namespace $ns -ClassName EnumerationAttribute -Filter "AttributeName='$($a.Nome)'" -ErrorAction SilentlyContinue
            if (-not $attr) { Write-Log "$($a.Id): BIOS Dell indisponível ou sem a opção '$($a.Nome)' (ignorado)"; continue }
            if ($attr.CurrentValue -eq $a.Valor) { Write-Log "$($a.Id): já aplicado"; continue }
            if ($attr.PossibleValue -notcontains $a.Valor) { Write-Log "$($a.Id): valor '$($a.Valor)' não aceito por esta BIOS" 'WARN'; continue }
            if (-not $PSCmdlet.ShouldProcess("BIOS $($a.Nome)", "$($attr.CurrentValue) -> $($a.Valor)")) { continue }
            Save-State -Id $a.Id -Data @{ Tipo = 'BiosDell'; Nome = $a.Nome; Valor = [string]$attr.CurrentValue } | Out-Null
            $r = (Get-WmiObject -Namespace $ns -Class BIOSAttributeInterface).SetAttribute(0, 0, 0, $a.Nome, $a.Valor)   # 0,0,0 = sem senha de BIOS
            if ($r.Status -ne 0) { Write-Log "$($a.Id): BIOS recusou (status $($r.Status); há senha de BIOS?)" 'WARN' }
            else { Write-Log "$($a.Id): aplicado, vale após reiniciar. $($a.Descricao)" }
        }
        else { Write-Log "$($a.Id): tipo desconhecido '$($a.Tipo)'" 'WARN' }
    } catch { Write-Log "$($a.Id): $($_.Exception.Message)" 'WARN' }
}
