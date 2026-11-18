# Otimização máxima — pesquisa e plano (13/11/2026)

Pesquisa feita com a skill `/pesquisar` (GitHub → Reddit/fóruns → web) mais um levantamento do hardware desta máquina. A parte 1 (seções 1–9) é a pesquisa. A **parte 2 (seção 10)** explica o que os vídeos de otimização fazem de verdade e o que virou script neste projeto. Nada foi aplicado na máquina ainda: os scripts precisam ser rodados como administrador.

Legenda de confiança: **[medido]** = lido desta máquina hoje · **[fonte]** = confirmado em link · **[não confirmado]** = conhecimento geral, sem fonte específica para este modelo.

---

## 1. Resumo: onde está o ganho de verdade

Em ordem de impacto estimado para este notebook:

| # | Ação | Ganho esperado | Custo / risco |
|---|------|----------------|---------------|
| 1 | **Colocar um segundo pente de RAM** (hoje é canal único) | O maior de todos: fóruns citam ~30–50% na GPU integrada e ~13% na CPU | Comprar 1 pente DDR4 SODIMM 3200 |
| 2 | Modo de energia "Melhor desempenho" + perfil térmico Dell "Ultra Performance" | CPU sustenta turbo por mais tempo | Mais ventoinha, mais calor, menos bateria |
| 3 | Remover software Dell/Intel supérfluo (Dell Optimizer, TechHub, Intel Connectivity) | Menos RAM e CPU em segundo plano; há relatos de vazamento de memória de GB | Perde os painéis da Dell |
| 4 | Desligar telemetria e serviços inúteis (seção 4) | Privacidade + algumas centenas de MB e menos disco/rede em segundo plano | Baixo, reversível |
| 5 | Remover apps pré-instalados e widgets/Copilot/Game Bar | ~150–400 MB de RAM | Baixo |
| 6 | Desligar Integridade de Memória (HVCI) | 0–10% em jogos, varia por título | **Reduz segurança** — decisão sua |

Desligar serviços sozinho **não** transforma a máquina: a maioria dos serviços "inúteis" já está parada (inicialização Manual) e não gasta nada. O gargalo real aqui é hardware (item 1).

---

## 2. Hardware levantado [medido]

| Item | Valor | Observação |
|------|-------|------------|
| Modelo | Dell Latitude 3420 | |
| CPU | Intel Core i5-1135G7 (Tiger Lake, 4 núcleos / 8 threads) | |
| RAM | **1 × 16 GB DDR4 3200** (slot "DIMM 1") | **Canal único** — só um pente instalado |
| GPU | Intel Iris Xe (driver 32.0.101.7088, 16/06/2026) | Usa a RAM do sistema; depende de canal duplo |
| SSD | ADATA SM2P41C3 NVMe 256 GB, saudável | Pequeno; manter 15–20% livre |
| BIOS | 1.49.0 (25/06/2026) | Recente |
| Wi-Fi | Intel AX201 (Wi-Fi 6) | |
| Energia | Plano **Equilibrado**; Modern Standby (S0), sem S3 | |
| Segurança | VBS ativo, com Integridade de Memória (HVCI) ligada; hipervisor presente | Docker/WSL usam o hipervisor |
| Serviços rodando | 150 | |
| RAM livre no momento | 6 GB de 15,7 GB | Com Roblox Studio (1 GB), Docker e Claude abertos |

### 2.1 RAM em canal único — o achado principal

- O Latitude 3420 tem **dois slots SODIMM**, DDR4 3200, máximo de 32 GB (4, 8 ou 16 GB por slot) [fonte: [especificações Dell](https://delltechnologies.com/asset/en-us/products/laptops-and-2-in-1s/technical-support/latitude-3420-technical-guidebook.pdf)].
- O Windows enxerga só um módulo. Com um pente, a memória roda em canal único.
- O i5-1135G7 foi projetado para DDR4-3200 em canal duplo [fonte: [Notebookcheck](https://www.notebookcheck.net/Intel-Tiger-Lake-U-Xe-Graphics-G7-80EUs-GPU-Benchmarks-and-Specs.466209.0.html)]. Um banco de dados de CPUs afirma que, em canal único, a Iris Xe passa a operar como "UHD Graphics", bem mais lenta [fonte: [CPU-Monkey](https://www.cpu-monkey.com/en/igpu-intel_iris_xe_graphics_96_tiger_lake)].
- Números citados em fórum (não é teste controlado): ~13% de CPU e ~30–50% de GPU com canal duplo em Iris Xe de 11ª geração [fonte: [Framework Community](https://community.frame.work/t/gaming-performance-on-the-igpu/36236)].

**O que fazer:** adicionar 1 × 16 GB DDR4 SODIMM 3200 (chega a 32 GB, o máximo). Um pente de 8 GB também ativa canal duplo em parte da memória, mas 16 + 16 é o ideal. Antes de comprar, abrir a tampa e confirmar que o segundo slot está vazio e existe nesta configuração.

Nenhum ajuste de software substitui isso. É o que mais afeta Roblox Studio e qualquer coisa gráfica.

---

## 3. Repositórios do GitHub

Estrelas e último push consultados em 13/11/2026 via `gh`.

### 3.1 Recomendados para este caso (Windows já instalado, mudanças reversíveis)

| Repositório | ★ | Último push | Para que serve | Observação |
|-------------|---|-------------|----------------|------------|
| [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) | 62,5 mil | 13/11/2026 | Script PowerShell: remove apps, desliga telemetria, anúncios, Copilot, Bing | O mais conservador; o README diz que tudo é reversível e tem [wiki de reversão](https://github.com/Raphire/Win11Debloat/wiki/Reverting-Changes) |
| [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) | 66 mil | 13/11/2026 | GUI com tweaks, serviços em Manual, telemetria, plano Ultimate Performance | Tem 69 tweaks em `config/tweaks.json` — boa **fonte de consulta** de chaves de registro |
| [farag2/Sophia-Script-for-Windows](https://github.com/farag2/Sophia-Script-for-Windows) | 10 mil | 12/11/2026 | Módulo PowerShell com ~150 funções, cada uma com seu "desfazer" | O mais granular; ideal para copiar ajustes individuais para este projeto |
| [undergroundwires/privacy.sexy](https://github.com/undergroundwires/privacy.sexy) | 6,2 mil | 13/02/2026 | Gera scripts de privacidade com script de reversão para cada item | Melhor catálogo de **telemetria**, com explicação de cada ajuste |
| [crazy-max/WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker) | 5,2 mil | 12/11/2026 | Listas de domínios/IPs de telemetria da Microsoft (hosts, firewall) | Bloqueio na rede, complementa desligar serviços |
| [memstechtips/Winhance](https://github.com/memstechtips/Winhance) | 14,9 mil | 12/11/2026 | App de otimização/customização com GUI | Alternativa ao winutil |
| [hellzerg/optimizer](https://github.com/hellzerg/optimizer) | 18,2 mil | 12/11/2026 | Otimizador com GUI | Popular; mesma linha |
| [builtbybel/Bloatynosy](https://github.com/builtbybel/Bloatynosy) | 5,9 mil | 12/11/2026 | Debloater com GUI | |
| [xM4ddy/OFGB](https://github.com/xM4ddy/OFGB) | 7,5 mil | 12/09/2024 | Só remove anúncios do Windows 11 | Parado há 2 anos; este projeto já cobre a maior parte |

### 3.2 Referência técnica (para ler, não para rodar)

| Repositório | ★ | Para que serve |
|-------------|---|----------------|
| [valleyofdoom/PC-Tuning](https://github.com/valleyofdoom/PC-Tuning) | 849 | Guia de tuning com medições; desmonta vários mitos |
| [djdallmann/GamingPCSetup](https://github.com/djdallmann/GamingPCSetup) | 1,1 mil | "Abordagem baseada em evidência" para configurar PC |
| [beatcracker/toptout](https://github.com/beatcracker/toptout) | 184 | Como desligar telemetria de ferramentas de desenvolvimento (CLI, SDKs) |

### 3.3 Não recomendados aqui

| Repositório | ★ | Por quê |
|-------------|---|---------|
| [Atlas-OS/Atlas](https://github.com/Atlas-OS/Atlas), [meetrevision/playbook](https://github.com/meetrevision/playbook) | 22 mil / 2,1 mil | "Playbooks" pensados para instalação limpa; mexem fundo no sistema e são difíceis de desfazer |
| [ntdevlabs/tiny11builder](https://github.com/ntdevlabs/tiny11builder) | 21,9 mil | Cria uma ISO enxuta — exige reinstalar o Windows |
| [ionuttbara/windows-defender-remover](https://github.com/ionuttbara/windows-defender-remover) | 8,7 mil | Remove o antivírus; ganho pequeno, risco grande |
| [Sycnex/Windows10Debloater](https://github.com/Sycnex/Windows10Debloater), [W4RH4WK/Debloat-Windows-10](https://github.com/W4RH4WK/Debloat-Windows-10), [LeDragoX/Win-Debloat-Tools](https://github.com/LeDragoX/Win-Debloat-Tools) | — | Arquivados |

**Sugestão de uso:** não rodar nenhum deles inteiro. Usar Sophia Script, privacy.sexy e o `tweaks.json` do winutil como catálogo e trazer os ajustes escolhidos para `config/ajustes.psd1`, para manter o `Save-State` e a reversão deste projeto.

---

## 4. Serviços desta máquina [medido]

Estado lido hoje. "Ganho" é estimativa.

### 4.1 Telemetria e envio de dados para a Microsoft — desligar

| Serviço | Nome | Estado atual | Ação | O que se perde |
|---------|------|--------------|------|----------------|
| `DiagTrack` | Experiências do Usuário Conectado e Telemetria | **Rodando**, Automático | Desativar | Nada de uso pessoal. É o principal serviço de telemetria [fonte: [ElevenForum](https://www.elevenforum.com/t/which-services-do-you-recommend-to-disable-here-is-my-list.36437/page-2)] |
| `dmwappushservice` | Roteamento de mensagens WAP Push | Parado, Manual | Desativar | Nada |
| `InventorySvc` | Avaliação de Inventário e Compatibilidade | **Rodando**, Automático | Manual | Coleta inventário de apps/hardware. Scripts da comunidade só o põem em Manual, não desativam |
| `PcaSvc` | Auxiliar de Compatibilidade de Programas | **Rodando**, Automático | Manual | Avisos de compatibilidade de programas antigos [não confirmado] |
| `whesvc` | Integridade e Experiências Otimizadas do Windows | **Rodando**, Automático | Testar em Manual | **Sem documentação clara** — não achei fonte que explique o efeito. Testar por último |
| `WerSvc` | Relatório de Erros do Windows | Parado, Manual | Desativar | Envio de relatórios de falha à Microsoft |
| `wisvc` | Programa Windows Insider | Parado, Manual | Desativar | Nada, se não usa Insider |
| `Intel Analytics Service` | Telemetria da Intel | Parado, Manual | Desativar | Nada |

### 4.2 Consomem recursos sem utilidade provável — avaliar

| Serviço | Nome | Estado atual | Ação | O que se perde |
|---------|------|--------------|------|----------------|
| `WSAIFabricSvc` | Host de Componentes de IA do Windows | **Rodando**, Automático | Desativar | Recall, Click to Do, Legendas ao Vivo [fonte: [ElevenForum](https://www.elevenforum.com/t/which-services-do-you-recommend-to-disable-here-is-my-list.36437/post-600240)]. Esta máquina não tem NPU, então pouco se aplica |
| `DoSvc` | Otimização de Entrega | **Rodando**, Automático | Limitar por política (`DODownloadMode=0`) | Deixa de enviar updates para outros PCs. Já acumulou ~5 GB de cache aqui (ver `memoria/pendente.md`) |
| `MapsBroker` | Gerenciador de Mapas Baixados | Parado, Automático | Desativar | Mapas offline |
| `lfsvc` | Geolocalização | **Rodando**, Manual | Desativar se não usa localização | Fuso automático, clima local, "Localizar meu dispositivo" |
| `PhoneSvc` | Telefonia | **Rodando**, Manual | Desativar + remover app Vincular ao Celular | Vincular ao Celular |
| `TrkWks` | Rastreamento de link distribuído | **Rodando**, Automático | Desativar | Só serve em rede com domínio/NTFS compartilhado |
| `Spooler` | Spooler de Impressão | **Rodando**, Automático | Desativar **só se nunca imprime** | Impressão, inclusive "Imprimir em PDF" |
| `SysMain` | Superfetch | **Rodando**, Automático | Manter (ou testar) | Fontes divergem: um usuário mediu menos de 0,2% de CPU, outras listas mandam desligar. Em SSD com 16 GB o efeito é pequeno nos dois sentidos |
| `WSearch` | Windows Search | **Rodando**, Automático | Manter, a menos que não use a busca | Busca de arquivos fica lenta. Alternativa: reduzir as pastas indexadas |
| `RetailDemo`, `WMPNetworkSvc`, `XblAuthManager`, `XblGameSave`, `XboxNetApiSvc`, `XboxGipSvc` | Demo de loja, mídia em rede, Xbox | Parados, Manual | Opcional | Já não consomem nada parados. Desativar é só higiene; Xbox pode ser necessário para jogos da Store/Game Pass |

### 4.3 Software Dell — maior fonte de desperdício de fabricante

| Item | Estado atual | Ação | Observação |
|------|--------------|------|------------|
| `DellTechHub` | **Rodando**, Automático | Desativar | Relatos de vazamento de memória (GB) no fórum Dell; um moderador indicou desativar o serviço como contorno [fonte: [Dell Community](https://www.dell.com/community/en/conversations/xps/memory-leak-with-dell-techhub/6784f1683ebe62063447a7b3)]. Há tópico específico do **Latitude 3420** com Dell Data Manager consumindo CPU e RAM [fonte: [Dell Community](https://www.dell.com/community/en/conversations/latitude/latitude-3420-dell-data-manager-process-is-using-high-cpu-and-ram-usage/681d5c2623e69c6fd36eaaa6)]. Perde o Dell Peripheral Manager |
| `DellInc.DellOptimizer` (app) | Instalado | Desinstalar via "Dell Optimizer Service" em Aplicativos [fonte: [Dell KB](https://www.dell.com/support/kbdoc/en-uk/000201618/how-to-troubleshoot-dell-optimizer)] | **Antes**, anotar o perfil térmico que ele usa e fixar na BIOS (seção 6) |
| `DellClientManagementService` | **Rodando**, Automático | Manual, testar | Não achei fonte oficial dizendo que é seguro remover. Pode ser usado por Dell Command Update |

Manter uma forma de atualizar BIOS e drivers: Dell Command | Update, ou baixar manualmente pela etiqueta de serviço em dell.com/support.

### 4.4 Software Intel / áudio

| Serviço | Estado | Ação | Motivo |
|---------|--------|------|--------|
| `esifsvc` (Intel Dynamic Tuning) | Rodando | **Não mexer** | Controla limites térmicos e de potência; sem ele o desempenho pode cair [não confirmado para este modelo] |
| `jhi_service`, `WMIRegistrationService` (Intel ME) | Rodando | Manter | Parte do firmware de gerenciamento |
| `cplspcon` (HDCP) | Rodando | Manter | Necessário para streaming com DRM (Netflix etc.) |
| `RtkAudioUniversalService`, `IntelAudioService` | Rodando | Manter | Áudio |
| `WavesAudioService`, `WavesSysSvc` | Rodando | Manter, ou testar | Em Dell costuma cuidar da detecção do fone e do equalizador [não confirmado] |
| `IDBWM`, `Intel Connectivity Network Service`, `IntelConnectService` | Rodando | Desinstalar "Intel Connectivity Performance Suite" | Só prioriza tráfego; dispensável [não confirmado] |
| `IntelGraphicsSoftwareService`, `igfxCUIService2.0.0.0` | Rodando | Opcional: desinstalar o painel "Intel Graphics Software" | O driver continua funcionando sem o painel |

### 4.5 Não desativar

`CDPSvc` (quebra páginas de Configurações e luz noturna), `WpnService` (notificações), `DPS` (diagnóstico de rede), `BITS`, `wuauserv` e demais serviços do Windows Update, tudo do Defender, `edgeupdate` (correções de segurança do Edge/WebView2).

Conselho recorrente nos fóruns: evitar mexer em serviços centrais, Windows Update e Defender [fonte: [Microsoft Tech Community](https://techcommunity.microsoft.com/discussions/windows11/is-ctt-debloat-damaging-on-windows-pc/4541984)].

---

## 5. Telemetria e desempenho além dos serviços

### 5.1 Telemetria

- **Limite do Windows 11 Pro:** não dá para zerar. `AllowTelemetry=0` só funciona em Enterprise/Education; no Pro é tratado como 1 ("dados obrigatórios") [fonte: [Microsoft Learn](https://learn.microsoft.com/en-us/windows/privacy/windows-privacy-compliance-guide), [PDQ](https://www.pdq.com/blog/how-to-disable-windows-telemetry/)]. O ajuste `Telemetria` deste projeto já usa o valor certo (1), mas **ainda não foi aplicado** — a chave de política não existe hoje [medido].
- Para ir além do limite do Pro: desativar `DiagTrack` (4.1) e bloquear os domínios de telemetria com as listas do [WindowsSpyBlocker](https://github.com/crazy-max/WindowsSpyBlocker).
- Tarefas agendadas de telemetria a desativar [não confirmado nesta build — conferir se existem]: `\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser`, `...\ProgramDataUpdater`, `\Customer Experience Improvement Program\Consolidator`, `...\UsbCeip`, `\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector`, `\Feedback\Siuf\DmClient`.
- Outras políticas úteis (catálogo no [privacy.sexy](https://github.com/undergroundwires/privacy.sexy) e [Sophia Script](https://github.com/farag2/Sophia-Script-for-Windows)): histórico de atividades, Copilot, Recall, sincronização da área de transferência na nuvem, envio de amostras de digitação/escrita, telemetria do Edge e do Office.

### 5.2 Já coberto por este projeto (`config/ajustes.psd1`)

Telemetria mínima, ID de publicidade, experiências personalizadas, recomendações e sugestões do Iniciar, dicas e anúncios da tela de bloqueio, busca Bing no Iniciar, Roblox e Edge fora da inicialização. Pendente de execução (ver `memoria/pendente.md`).

### 5.3 Lacunas — o que falta no projeto

| Ajuste | Efeito | Observação |
|--------|--------|------------|
| Modo de energia "Melhor desempenho" | CPU mais agressiva | Em máquinas com Modern Standby só o plano Equilibrado aparece; o ajuste é pelo controle "Modo de energia" em Configurações → Energia [não confirmado] |
| Remover apps: `Microsoft.Windows.DevHome`, `BingWeather`, `BingSearch`, `GetHelp`, `ZuneMusic`, `YourPhone`, `XboxGamingOverlay`, `XboxSpeechToTextOverlay` [medido: instalados] | Menos processos em segundo plano | O processo `GameBar` usa 139 MB agora. Remover o overlay pode gerar um aviso "ms-gamingoverlay" ao abrir jogos; o Win11Debloat trata isso |
| Desligar Widgets e Copilot | Menos processos WebView2 | |
| Edge: desligar "Inicialização rápida" e "Continuar executando em segundo plano" | Menos RAM com o Edge fechado | |
| Apps em segundo plano e itens de inicialização | Menos RAM | Revisar em Gerenciador de Tarefas → Inicialização |
| Exclusões do Defender para pastas de build/desenvolvimento | `MsMpEng` usa 382 MB e varre cada arquivo gravado | Reduz proteção nessas pastas — excluir só o necessário |
| Efeitos visuais (transparência, animações) | Alívio pequeno na GPU integrada | |
| `DODownloadMode=0` | Para o envio de updates a terceiros | |
| Integridade de Memória (HVCI) | 0–10% em jogos | Ver 5.4 |

Quase toda esta tabela virou ajuste em `config/ajustes.psd1` (ver seção 10). Ficaram manuais: exclusões do Defender, revisão dos itens de inicialização e HVCI.

### 5.4 VBS / Integridade de Memória — decisão sua

- Está ligada [medido]. A Microsoft admite que máquinas sensíveis a desempenho podem vir com HVCI desligado e lista Integridade de Memória e Plataforma de Máquina Virtual como recursos que podem reduzir desempenho em jogos, avisando que desligar deixa o aparelho mais vulnerável [fonte: [Tom's Hardware](https://www.tomshardware.com/news/windows-11-gaming-benchmarks-performance-vbs-hvci-security), [TechSpot](https://www.techspot.com/news/96246-microsoft-releases-guide-optimize-windows-11-gaming-performance.html)].
- Medições variam: de "praticamente nada" [fonte: [PCWorld](https://www.pcworld.com/article/541137/tested-does-windows-11-nuke-gaming-performance.html)] a até 10% [fonte: [Tom's Hardware](https://www.tomshardware.com/news/windows-vbs-harms-performance-rtx-4090)] e ~8% no 24H2 [fonte: [ComputerBase](https://www.computerbase.de/2023-03/windows-11-vbs-hvci-spiele-benchmarks/)]. Os testes são de 2021–2024 e em desktops com GPU dedicada, não em Iris Xe.
- Como você usa Docker/WSL, o hipervisor continua ligado de qualquer forma; só a Integridade de Memória poderia ser desligada (Segurança do Windows → Segurança do dispositivo → Isolamento de núcleo).
- Recomendação: deixar ligada. Só testar depois de resolver a RAM, medindo antes e depois.

---

## 6. BIOS (F2 na inicialização)

Valores lidos desta máquina em 13/11/2026 pelo WMI da Dell (`root\dcim\sysman\biosattributes`) [medido].

### 6.0 O que mudar

| Opção (nome no WMI) | Valor atual | Mudar para | Motivo | No script? |
|---------------------|-------------|------------|--------|------------|
| `ThermalManagement` | **Cool** | **UltraPerformance** | "Cool" prioriza temperatura baixa e segura a CPU. É o ajuste de BIOS que mais pesa aqui. Mais ruído e calor | Sim, só com `-Maximo` |
| `Fastboot` | Thorough | Minimal | POST mais curto, boot mais rápido | Sim |
| `TelemetryAccessLvl` | **Full** | Disabled | Telemetria do próprio firmware para a Dell | Sim |
| `PrimaryBattChargeCfg` | Express | Adaptive, Standard ou PrimAcUse | Carga expressa desgasta mais a bateria; não muda desempenho | Não (preferência) |
| `SecureBoot` | **Disabled** | Enabled (avaliar) | Não é desempenho, é segurança; alguns jogos com anticheat exigem | Não |

### 6.0.1 Já está certo — não mexer

| Opção | Valor atual | Observação |
|-------|-------------|------------|
| `TurboMode`, `Speedstep`, `SpeedShift`, `CStatesCtrl` | Enabled | Desligar qualquer um reduz desempenho ou só aumenta calor |
| `LogicProc` (Hyper-Threading), `CpuCore` | Enabled / CoresAll | Todos os núcleos e threads ativos |
| `Virtualization`, `VtForDirectIo` | Enabled | Necessário para Docker/WSL |
| `EmbSataRaid` | Ahci | **Não trocar** com o Windows instalado: a troca impede o boot |
| `Absolute` | PermanentlyDisabled | Rastreamento antifurto já desativado em definitivo |
| `BlockSleep`, `WakeOnLan`, `WakeOnAc` | Disabled | |

### 6.0.2 Opcionais, sem efeito em desempenho

`BIOSConnect`, `SupportAssistOSRecovery`, `BiosRcvrFrmHdd` (recuperação pela Dell; desligar só tira a rede de segurança), `EcoPower` (Enabled; não confirmei o que controla neste modelo — deixar).

Os três ajustes marcados "Sim" são aplicados pelo tipo `BiosDell` do `04-ajustes.ps1`, que chama o método `SetAttribute` da interface WMI da Dell e salva o valor anterior para o `reverter.ps1`. **Ainda não foi testado gravando** (a sessão não era de administrador). Se a BIOS tiver senha, o script avisa e não altera. Vale após reiniciar. Alternativa manual: F2 → Power → Thermal Management.

Para reler os valores, em terminal de administrador:

```powershell
Get-CimInstance -Namespace root\dcim\sysman\biosattributes -ClassName EnumerationAttribute |
    Sort-Object AttributeName | Format-Table AttributeName, CurrentValue, PossibleValue -AutoSize
```

Atenção: há um KB da Dell dizendo que em alguns 3420 certas opções não mudam sem reset do RTC [fonte: [Dell KB 000372620](https://www.dell.com/support/kbdoc/en-us/000372620/bios-options-cannot-be-changed-on-certain-latitudes)]. O Dell Optimizer também troca o perfil térmico pelo Windows; se ele continuar instalado, pode sobrescrever o valor da BIOS [não confirmado].

Não existe overclock nem undervolt nesta plataforma [não confirmado].

### 6.1 Físico (fora da BIOS)

- **RAM em canal duplo** — seção 2.1.
- Limpar ventoinha/dissipador e trocar a pasta térmica: notebook de 2021; se estiver limitando por temperatura, nenhum ajuste compensa [não confirmado: não medi temperaturas].
- SSD de 256 GB: o slot M.2 aceita maior. Pouco espaço livre degrada a escrita e o projeto já sofreu com disco cheio.

---

## 7. O que não fazer

| Mito / prática | Por quê |
|----------------|---------|
| Desativar o arquivo de paginação | Com 16 GB e Docker + Roblox Studio, causa travamentos por falta de memória |
| "Limpadores de RAM" e otimizadores milagrosos | Só forçam paginação; piora o desempenho |
| Remover Defender ou Windows Update | Ganho pequeno, risco grande |
| Desligar mitigações de CPU (Spectre etc.) | Ganho marginal nesta geração, perda de segurança |
| Aplicar um preset inteiro de debloat sem ler | Um teste relatou script marcando como "lixo" apps em uso [fonte: [Make Tech Easier](https://maketecheasier.com/why-windows-debloat-scripts-do-more-harm-than-good)] |
| Baixar scripts de sites que não sejam o repositório oficial | Cópias podem ser adulteradas [fonte: [Gridinsoft](https://blog.gridinsoft.com/win11debloat-safety/)] |
| Atlas/ReviOS/tiny11 nesta instalação | Feitos para instalação limpa |

---

## 8. Ordem sugerida

1. Concluir o que está em `memoria/pendente.md` (backup + 14 ajustes já escritos). Precisa de terminal como administrador.
2. Comprar e instalar o segundo pente de RAM.
3. Ler a BIOS com o comando da seção 6 e ajustar Thermal Management.
4. Desinstalar Dell Optimizer e Intel Connectivity; desativar `DellTechHub`.
5. Estender `04-ajustes.ps1` para serviços, tarefas e apps, e aplicar as seções 4.1, 4.2 e 5.3 em lotes pequenos, reiniciando e usando a máquina entre eles.
6. Só então decidir sobre HVCI, medindo antes e depois.

---

## 9. Incertezas e divergências

- **Reddit:** a busca `site:reddit.com` quase não trouxe tópicos do Reddit; a parte de comunidade veio de ElevenForum, Dell Community, Lemmy e Microsoft Tech Community.
- **Hacker News:** só discussões pequenas, sem conteúdo aproveitável.
- **BIOS:** valores lidos da máquina, mas a gravação pelo script ainda não foi testada.
- **`whesvc`, `InventorySvc`, `DellClientManagementService`:** nenhuma fonte explica com segurança o efeito de desativar.
- **`SysMain`:** fontes divergem.
- **Ganho de canal duplo e de HVCI:** os percentuais vêm de fóruns e de testes em outro hardware; não medi nesta máquina.
- **Lista de serviços do winutil:** não consegui extrair a lista exata de serviços do `tweaks.json` na versão atual; a seção 4 foi montada a partir do estado real desta máquina, não copiada dele.

---

## 10. Parte 2 — o que os vídeos fazem de verdade e o que virou script

### 10.1 Expectativa honesta

Os vídeos em que o Windows "vira outro sistema" quase sempre fazem uma destas duas coisas:

1. **Reinstalam com uma imagem capada** (Atlas, ReviOS, tiny11): removem Defender, Update, Store e componentes inteiros. É daí que vem o salto, e também o que quebra depois.
2. **Rodam um script de debloat em uma instalação nova e cheia de lixo**, em máquina fraca (4–8 GB, HD mecânico), onde qualquer alívio aparece.

Em um Windows já instalado, com 16 GB e SSD, o que scripts conseguem é: menos processos em segundo plano, menos disco e rede ociosos, interface mais direta e nada sendo enviado à Microsoft/Dell. Isso é perceptível no uso, mas não dobra FPS. Os dois ajustes que mexem em desempenho bruto aqui são o perfil térmico da BIOS (estava em **Cool**) e o modo de energia (estava em Equilibrado).

### 10.2 O que os scripts famosos alteram, item por item

Lido direto do código em 13/11/2026: [`tweaks.json` do winutil](https://github.com/ChrisTitusTech/winutil/blob/main/config/tweaks.json) (69 tweaks) e os [`Regfiles` do Win11Debloat](https://github.com/Raphire/Win11Debloat/tree/master/Regfiles).

| O que o vídeo mostra | O que é feito por baixo | Efeito real | Neste projeto |
|----------------------|-------------------------|-------------|---------------|
| "Desativar telemetria" | ~12 valores de registro (ID de publicidade, fala online, digitação, feedback, histórico de atividades), serviços `DiagTrack` e `WerSvc` desativados | Privacidade; pouco desempenho | **Sim** |
| "Desativar serviços inúteis" | No winutil atual são só **5 serviços**: `DiagTrack`, `CscService`, `SharedAccess` (desativados), `MapsBroker`, `StorSvc` (manual) | Pequeno. As listas de "100 serviços" que circulam mexem em serviços que já estão parados | **Sim**, lista montada com o que roda nesta máquina |
| "Remover bloatware" | `Remove-AppxPackage` em uma lista (o Win11Debloat tem 162 apps catalogados) | Menos processos e atualizações em segundo plano | **Sim** |
| "Tirar Copilot, Recall e IA" | Políticas `TurnOffWindowsCopilot`, `DisableAIDataAnalysis`, `AllowRecallEnablement`; serviço `WSAIFabricSvc` em Manual | Menos RAM | **Sim** |
| "Tirar Widgets" | winutil remove os pacotes; aqui uso a política `AllowNewsAndInterests=0` | Some o processo WebView2 dos widgets | **Sim** (por política, reversível) |
| "Desativar Game DVR" | `GameDVR_Enabled=0`, `AppCaptureEnabled=0`, `AllowGameDVR=0` | Sem gravação em segundo plano durante jogos | **Sim** (Modo Jogo continua ligado) |
| "Efeitos visuais para desempenho" | Transparência, animações de janela e da barra, atraso de menu | Interface responde mais rápido; o PC-Tuning mediu um pequeno custo de CPU da transparência [fonte: [PC-Tuning](https://github.com/valleyofdoom/PC-Tuning)] | **Sim** (parcial: sem mexer em fontes e miniaturas) |
| "Otimização de entrega" | `DODownloadMode=0` | Para de enviar updates a outros PCs | **Sim** |
| "Apps em segundo plano" | winutil: `GlobalUserDisabled=1`; aqui a política `LetAppsRunInBackground=2` | Menos RAM; perde notificações de apps da Store fechados | **Sim**, só com `-Maximo` |
| "Desativar Superfetch/SysMain" | Serviço `SysMain` desativado | O PC-Tuning recomenda quando não há HD mecânico, citando o guia de tempo real da Microsoft [fonte: [PC-Tuning](https://github.com/valleyofdoom/PC-Tuning#superfetch-and-prefetch), [Microsoft Learn](https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/soft-real-time/soft-real-time-device)]. Outras fontes mediram efeito desprezível | **Sim**, só com `-Maximo` |
| "Desativar indexação" | Serviço `WSearch` desativado. O winutil classifica como avançado e diz que serve principalmente para HD mecânico | Menos disco em segundo plano; busca de arquivos fica lenta | **Sim**, só com `-Maximo` |
| "Plano Desempenho Máximo" | `powercfg` duplicando o plano oculto. O winutil rotula como **"NOT FOR LAPTOPS"** | Em notebook com Modern Standby o plano nem aparece; o equivalente é o modo "Melhor desempenho" | **Sim**, via modo de energia (testado nesta máquina) |
| "Desativar hibernação" | `powercfg /hibernate off` | Libera espaço em disco, não acelera | Não (é notebook) |
| "Timer resolution / ISLC" | Programa que força o temporizador a 0,5 ms | Desde o Windows 10 2004, um processo que aumenta a resolução **não afeta os outros** [fonte: [PC-Tuning](https://github.com/valleyofdoom/PC-Tuning#clock-interrupt-frequency-timer-resolution), [Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/api/timeapi/nf-timeapi-timebeginperiod), [Random ASCII](https://randomascii.wordpress.com/2020/10/04/windows-timer-resolution-the-great-rule-change)] | Não |
| "Tweaks de registro de latência" (`Win32PrioritySeparation`, `SystemResponsiveness`, `NetworkThrottlingIndex`), `bcdedit` (`useplatformclock`, `disabledynamictick`), "core parking" | Valores de registro e de boot | Não encontrei medição confiável de ganho nesta pesquisa | Não |
| "Dividir menos o svchost" | `SvcHostSplitThresholdInKB` | O próprio winutil recomenda só para 12 GB ou menos | Não |
| "Desligar Integridade de Memória" | Isolamento de núcleo | 0–10% em jogos, com perda de segurança (seção 5.4) | Não (manual) |
| "Remover Defender / pausar Update para sempre" | Scripts de terceiros | Risco alto | Não |

### 10.3 Como usar (nesta máquina ou em outra)

1. Copiar a pasta do projeto para o PC (ou `git clone`).
2. Duplo clique em **`OTIMIZAR.cmd`**. Ele pede elevação e mostra o menu:

| Opção | O que faz |
|-------|-----------|
| 1 — Simular | Mostra tudo o que seria alterado, sem alterar nada |
| 2 — Seguro | Diagnóstico, ponto de restauração, ajustes sem perda de função, TRIM |
| 3 — Máximo | O mesmo, mais os itens com perda de função (10.4) |
| 4 — Reverter | Desfaz tudo a partir de `estado\estado.json` |

3. Reiniciar.

Pela linha de comando, como administrador:

```powershell
.\executar.ps1 -Etapas 0145 -Maximo -WhatIf   # simula
.\executar.ps1 -Etapas 0145 -Maximo           # aplica
.\reverter.ps1                                # desfaz tudo
.\reverter.ps1 -Id Svc-WSearch,UI-Transparencia   # desfaz só alguns
```

`-Etapas` escolhe as etapas pelo número (0 diagnóstico, 1 backup, 2 limpeza, 3 reparo, 4 ajustes, 5 manutenção). O lançador pula 2 e 3 porque o reparo (`sfc`) leva horas.

**Portabilidade:** serviço, tarefa, app ou opção de BIOS que não existir no PC é ignorado com uma linha no log, então o mesmo arquivo serve para máquinas que não são Dell. O script pode ser rodado de novo a qualquer momento (pula o que já está aplicado) — útil depois de uma atualização grande do Windows, que costuma religar parte disso.

**Para personalizar:** cada ajuste é uma linha em `config\ajustes.psd1`. Apagar a linha tira o ajuste; `Maximo = $true` o restringe ao modo máximo. `StartupRoblox` é pessoal desta máquina e inofensivo nas outras.

### 10.4 O que o modo Máximo adiciona — e o que se perde

| Id | Ajuste | Perde |
|----|--------|-------|
| `Bios-Termico` | Perfil térmico Ultra Performance (só Dell) | Silêncio e temperatura; mais consumo |
| `Svc-WSearch` | Indexação desligada | Busca de arquivos fica lenta (apps ainda aparecem no Iniciar) |
| `Svc-SysMain` | Superfetch desligado | Apps podem abrir um pouco mais devagar na primeira vez |
| `Svc-lfsvc` | Geolocalização desligada | Fuso automático, clima local, Localizar meu dispositivo |
| `Svc-PhoneSvc`, `App-YourPhone` | Telefonia e Vincular ao Celular | Integração com o celular |
| `AppsSegundoPlano` | Apps da Store não rodam fechados | Notificações desses apps |
| `Svc-whesvc`, `Svc-DellClientMgmt` | Em Manual | Efeito pouco documentado; o segundo pode afetar o Dell Command Update |

### 10.5 Continua manual

| Item | Como |
|------|------|
| Desinstalar Dell Optimizer e Intel Connectivity Performance Suite | Configurações → Aplicativos. São instaladores comuns, não apps da Store |
| Itens de inicialização | Gerenciador de Tarefas → Aplicativos de inicialização |
| Integridade de Memória (HVCI) | Segurança do Windows → Isolamento de núcleo. Decisão de segurança |
| Exclusões do Defender para pastas de build | Reduz proteção; escolher pasta a pasta |
| Carga da bateria e Secure Boot | BIOS (seção 6) |
| Segundo pente de RAM | Seção 2.1 — continua sendo o maior ganho |

### 10.6 Limites e o que não foi testado

- **Nada foi aplicado de verdade.** Só rodei a simulação (`-WhatIf`) e os testes, que passam. A sessão não era de administrador.
- **BIOS:** a leitura funciona; a gravação pelo WMI da Dell não foi testada.
- **Modo de energia:** o comando foi testado nesta máquina (aplicou e voltou ao original).
- **Serviços e tarefas protegidos:** o Windows pode recusar alguns mesmo como administrador (comum nas tarefas de `Application Experience`). O script registra um aviso e segue.
- **Apps:** são removidos só do usuário atual; o reverter re-registra o pacote se ele ainda estiver no sistema, senão pede reinstalar pela Store. Usuários novos ainda recebem os apps.
- **Serviços com início "Automático (atraso)"** voltam como "Automático" ao reverter.
- **Conta:** os ajustes de usuário (`HKCU`) valem para a conta que rodou o script. Se a elevação for feita com outra conta, eles caem na conta errada.
- **Edge e Configurações** passam a mostrar "gerenciado pela organização", por causa das políticas.
- **`OTIMIZAR.cmd`:** o menu não foi executado nesta sessão (exige a janela de elevação).
