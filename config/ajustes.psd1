@{
    Ajustes = @(
        @{ Id = 'Telemetria'; Descricao = 'Telemetria mínima (AllowTelemetry=1). Aviso: Configurações mostrará "gerenciado pela organização".'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Nome = 'AllowTelemetry'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'IdPublicidade'; Descricao = 'Desliga ID de publicidade'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Nome = 'Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'ExperienciasPersonalizadas'; Descricao = 'Desliga experiências personalizadas com dados de diagnóstico'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'; Nome = 'TailoredExperiencesWithDiagnosticDataEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'RecomendacoesIniciar'; Descricao = 'Desliga recomendações no Iniciar'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Nome = 'Start_IrisRecommendations'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-SystemPaneSuggestions'; Descricao = 'Sem sugestões no Iniciar'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SystemPaneSuggestionsEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-SoftLanding'; Descricao = 'Sem dicas de boas-vindas'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SoftLandingEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-338388'; Descricao = 'Sem conteúdo sugerido 338388'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-338388Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-338389'; Descricao = 'Sem conteúdo sugerido 338389'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-338389Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-338393'; Descricao = 'Sem conteúdo sugerido 338393'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-338393Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-353694'; Descricao = 'Sem conteúdo sugerido 353694'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-353694Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-353696'; Descricao = 'Sem conteúdo sugerido 353696'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-353696Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-338387'; Descricao = 'Sem dicas na tela de bloqueio (338387)'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'SubscribedContent-338387Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'CDM-LockScreenOverlay'; Descricao = 'Sem anúncios sobre a tela de bloqueio (Spotlight continua)'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Nome = 'RotatingLockScreenOverlayEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'BingIniciar'; Descricao = 'Sem busca Bing no Iniciar'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'; Nome = 'DisableSearchBoxSuggestions'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'StartupRoblox'; Descricao = 'Remove Roblox da inicialização'; Tipo = 'StartupRemover'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; Padrao = 'RobloxPlayerBeta*' }

        # ===== Otimização máxima (ver OTIMIZACAO_MAXIMA.md, parte 2). Itens com Maximo = $true só rodam com -Maximo. =====

        # --- Telemetria e coleta (fonte: winutil "Telemetry - Disable", Win11Debloat Disable_Telemetry.reg) ---
        @{ Id = 'Tel-FalaOnline'; Descricao = 'Sem reconhecimento de fala online'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'; Nome = 'HasAccepted'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Tel-Digitacao'; Descricao = 'Sem envio de dados de digitação/escrita'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Input\TIPC'; Nome = 'Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Tel-ColetaTinta'; Descricao = 'Sem coleta implícita de tinta'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\InputPersonalization'; Nome = 'RestrictImplicitInkCollection'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'Tel-ColetaTexto'; Descricao = 'Sem coleta implícita de texto'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\InputPersonalization'; Nome = 'RestrictImplicitTextCollection'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'Tel-Contatos'; Descricao = 'Sem coleta de contatos'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore'; Nome = 'HarvestContacts'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Tel-Feedback'; Descricao = 'Windows nunca pede feedback'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Siuf\Rules'; Nome = 'NumberOfSIUFInPeriod'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Tel-AtividadesPublicar'; Descricao = 'Histórico de atividades não é publicado'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Nome = 'PublishUserActivities'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Tel-AtividadesEnviar'; Descricao = 'Histórico de atividades não é enviado'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Nome = 'UploadUserActivities'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'AppsPromovidos'; Descricao = 'Sem instalação automática de apps promovidos'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Nome = 'DisableWindowsConsumerFeatures'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'EntregaP2P'; Descricao = 'Updates não são enviados a outros PCs (Delivery Optimization só HTTP)'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Nome = 'DODownloadMode'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'WPBT'; Descricao = 'Fabricante não injeta programas pelo firmware no boot (WPBT)'; Tipo = 'Registro'; Caminho = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'; Nome = 'DisableWpbtExecution'; Valor = 1; TipoValor = 'DWord' }

        # --- Copilot, Recall, Widgets (fonte: Win11Debloat Disable_Copilot.reg / Disable_AI_Recall.reg) ---
        @{ Id = 'Copilot'; Descricao = 'Copilot desligado (política)'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'; Nome = 'TurnOffWindowsCopilot'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'CopilotBotao'; Descricao = 'Sem botão do Copilot na barra'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Nome = 'ShowCopilotButton'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'RecallAnalise'; Descricao = 'Recall: sem análise de dados por IA'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Nome = 'DisableAIDataAnalysis'; Valor = 1; TipoValor = 'DWord' }
        @{ Id = 'RecallAtivar'; Descricao = 'Recall não pode ser ativado'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Nome = 'AllowRecallEnablement'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Widgets'; Descricao = 'Widgets desligados (política; some o processo WebView2 deles)'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Nome = 'AllowNewsAndInterests'; Valor = 0; TipoValor = 'DWord' }

        # --- Gravação de jogos em segundo plano (fonte: Win11Debloat Disable_DVR.reg). Modo Jogo continua ligado. ---
        @{ Id = 'DVR-Config'; Descricao = 'Game DVR desligado'; Tipo = 'Registro'; Caminho = 'HKCU:\System\GameConfigStore'; Nome = 'GameDVR_Enabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'DVR-Captura'; Descricao = 'Captura de apps desligada'; Tipo = 'Registro'; Caminho = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'; Nome = 'AppCaptureEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'DVR-Politica'; Descricao = 'Game DVR bloqueado por política'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Nome = 'AllowGameDVR'; Valor = 0; TipoValor = 'DWord' }

        # --- Edge em segundo plano. Aviso: o Edge mostrará "gerenciado pela organização". ---
        @{ Id = 'Edge-StartupBoost'; Descricao = 'Edge não pré-carrega no logon'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Nome = 'StartupBoostEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Edge-SegundoPlano'; Descricao = 'Edge não continua rodando depois de fechado'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Nome = 'BackgroundModeEnabled'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Edge-Diagnostico'; Descricao = 'Edge sem dados de diagnóstico'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Nome = 'DiagnosticData'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'Edge-Personalizacao'; Descricao = 'Edge não envia histórico para personalizar anúncios'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Nome = 'PersonalizationReportingEnabled'; Valor = 0; TipoValor = 'DWord' }

        # --- Interface mais direta (fonte: winutil "Visual Effects", Win11Debloat Disable_Transparency/Startup_Delay) ---
        @{ Id = 'UI-Transparencia'; Descricao = 'Sem transparência (alivia a GPU integrada)'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Nome = 'EnableTransparency'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'UI-AnimJanelas'; Descricao = 'Sem animação de minimizar/maximizar'; Tipo = 'Registro'; Caminho = 'HKCU:\Control Panel\Desktop\WindowMetrics'; Nome = 'MinAnimate'; Valor = '0'; TipoValor = 'String' }
        @{ Id = 'UI-AnimBarra'; Descricao = 'Sem animações na barra de tarefas'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Nome = 'TaskbarAnimations'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'UI-AtrasoMenu'; Descricao = 'Menus abrem em 200 ms (padrão 400)'; Tipo = 'Registro'; Caminho = 'HKCU:\Control Panel\Desktop'; Nome = 'MenuShowDelay'; Valor = '200'; TipoValor = 'String' }
        @{ Id = 'UI-AtrasoInicializacao'; Descricao = 'Apps de inicialização abrem sem atraso artificial'; Tipo = 'Registro'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'; Nome = 'Startupdelayinmsec'; Valor = 0; TipoValor = 'DWord' }
        @{ Id = 'AppsSegundoPlano'; Maximo = $true; Descricao = 'Apps da Store não rodam em segundo plano. Perde: notificações de apps da Store fechados'; Tipo = 'Registro'; Caminho = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Nome = 'LetAppsRunInBackground'; Valor = 2; TipoValor = 'DWord' }

        # --- Serviços. Inicio = Disabled | Manual. Serviço que não existe no PC é ignorado. ---
        @{ Id = 'Svc-DiagTrack'; Descricao = 'Telemetria (Experiências do Usuário Conectado)'; Tipo = 'Servico'; Nome = 'DiagTrack'; Inicio = 'Disabled' }
        @{ Id = 'Svc-dmwappush'; Descricao = 'Roteamento WAP Push (telemetria)'; Tipo = 'Servico'; Nome = 'dmwappushservice'; Inicio = 'Disabled' }
        @{ Id = 'Svc-WerSvc'; Descricao = 'Relatório de erros para a Microsoft'; Tipo = 'Servico'; Nome = 'WerSvc'; Inicio = 'Disabled' }
        @{ Id = 'Svc-wisvc'; Descricao = 'Windows Insider'; Tipo = 'Servico'; Nome = 'wisvc'; Inicio = 'Disabled' }
        @{ Id = 'Svc-RetailDemo'; Descricao = 'Modo demonstração de loja'; Tipo = 'Servico'; Nome = 'RetailDemo'; Inicio = 'Disabled' }
        @{ Id = 'Svc-TrkWks'; Descricao = 'Rastreamento de links (só útil em domínio)'; Tipo = 'Servico'; Nome = 'TrkWks'; Inicio = 'Disabled' }
        @{ Id = 'Svc-MapsBroker'; Descricao = 'Mapas offline'; Tipo = 'Servico'; Nome = 'MapsBroker'; Inicio = 'Manual' }
        @{ Id = 'Svc-InventorySvc'; Descricao = 'Inventário de compatibilidade'; Tipo = 'Servico'; Nome = 'InventorySvc'; Inicio = 'Manual' }
        @{ Id = 'Svc-PcaSvc'; Descricao = 'Assistente de compatibilidade de programas'; Tipo = 'Servico'; Nome = 'PcaSvc'; Inicio = 'Manual' }
        @{ Id = 'Svc-WSAIFabric'; Descricao = 'Componentes de IA do Windows (como no Win11Debloat: Manual)'; Tipo = 'Servico'; Nome = 'WSAIFabricSvc'; Inicio = 'Manual' }
        @{ Id = 'Svc-IntelAnalytics'; Descricao = 'Telemetria da Intel'; Tipo = 'Servico'; Nome = 'Intel Analytics Service'; Inicio = 'Disabled' }
        @{ Id = 'Svc-DellTechHub'; Descricao = 'Dell TechHub (relatos de vazamento de memória). Perde: Dell Peripheral Manager'; Tipo = 'Servico'; Nome = 'DellTechHub'; Inicio = 'Disabled' }
        @{ Id = 'Svc-SysMain'; Maximo = $true; Descricao = 'Superfetch. Só vale em SSD; apps podem abrir um pouco mais devagar na 1ª vez'; Tipo = 'Servico'; Nome = 'SysMain'; Inicio = 'Disabled' }
        @{ Id = 'Svc-WSearch'; Maximo = $true; Descricao = 'Indexação do Windows Search. Perde: busca de arquivos fica lenta (apps continuam aparecendo)'; Tipo = 'Servico'; Nome = 'WSearch'; Inicio = 'Disabled' }
        @{ Id = 'Svc-lfsvc'; Maximo = $true; Descricao = 'Geolocalização. Perde: fuso automático, clima local, Localizar meu dispositivo'; Tipo = 'Servico'; Nome = 'lfsvc'; Inicio = 'Disabled' }
        @{ Id = 'Svc-PhoneSvc'; Maximo = $true; Descricao = 'Telefonia. Perde: Vincular ao Celular'; Tipo = 'Servico'; Nome = 'PhoneSvc'; Inicio = 'Disabled' }
        @{ Id = 'Svc-whesvc'; Maximo = $true; Descricao = 'Integridade e Experiências Otimizadas (efeito pouco documentado)'; Tipo = 'Servico'; Nome = 'whesvc'; Inicio = 'Manual' }
        @{ Id = 'Svc-DellClientMgmt'; Maximo = $true; Descricao = 'Dell Client Management (pode ser usado pelo Dell Command Update)'; Tipo = 'Servico'; Nome = 'DellClientManagementService'; Inicio = 'Manual' }

        # --- Tarefas agendadas de telemetria. Todas conferidas neste Windows 11 25H2; a que não existir é ignorada. ---
        @{ Id = 'Task-Appraiser'; Descricao = 'Avaliador de compatibilidade'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Application Experience\'; Nome = 'Microsoft Compatibility Appraiser' }
        @{ Id = 'Task-AppraiserExp'; Descricao = 'Avaliador de compatibilidade (Exp)'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Application Experience\'; Nome = 'Microsoft Compatibility Appraiser Exp' }
        @{ Id = 'Task-MareBackup'; Descricao = 'Coleta de inventário (MareBackup)'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Application Experience\'; Nome = 'MareBackup' }
        @{ Id = 'Task-StartupApp'; Descricao = 'Varredura de apps de inicialização'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Application Experience\'; Nome = 'StartupAppTask' }
        @{ Id = 'Task-PcaPatchDb'; Descricao = 'Base do assistente de compatibilidade'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Application Experience\'; Nome = 'PcaPatchDbTask' }
        @{ Id = 'Task-Consolidator'; Descricao = 'Programa de melhoria (CEIP)'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Customer Experience Improvement Program\'; Nome = 'Consolidator' }
        @{ Id = 'Task-UsbCeip'; Descricao = 'CEIP de USB'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Customer Experience Improvement Program\'; Nome = 'UsbCeip' }
        @{ Id = 'Task-AutochkProxy'; Descricao = 'Telemetria do autochk'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Autochk\'; Nome = 'Proxy' }
        @{ Id = 'Task-DiskDiag'; Descricao = 'Coletor de diagnóstico de disco'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\DiskDiagnostic\'; Nome = 'Microsoft-Windows-DiskDiagnosticDataCollector' }
        @{ Id = 'Task-DmClient'; Descricao = 'Feedback (Siuf)'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Feedback\Siuf\'; Nome = 'DmClient' }
        @{ Id = 'Task-DmClientDownload'; Descricao = 'Feedback (Siuf) download'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Feedback\Siuf\'; Nome = 'DmClientOnScenarioDownload' }
        @{ Id = 'Task-QueueReporting'; Descricao = 'Fila de relatórios de erro'; Tipo = 'Tarefa'; Pasta = '\Microsoft\Windows\Windows Error Reporting\'; Nome = 'QueueReporting' }

        # --- Apps pré-instalados (subconjunto da lista padrão do Win11Debloat). Removidos só do usuário atual. ---
        @{ Id = 'App-DevHome'; Descricao = 'Dev Home (descontinuado)'; Tipo = 'App'; Nome = 'Microsoft.Windows.DevHome' }
        @{ Id = 'App-BingWeather'; Descricao = 'Clima'; Tipo = 'App'; Nome = 'Microsoft.BingWeather' }
        @{ Id = 'App-BingNews'; Descricao = 'Notícias'; Tipo = 'App'; Nome = 'Microsoft.BingNews' }
        @{ Id = 'App-BingSearch'; Descricao = 'Busca Bing'; Tipo = 'App'; Nome = 'Microsoft.BingSearch' }
        @{ Id = 'App-GetHelp'; Descricao = 'Obter Ajuda'; Tipo = 'App'; Nome = 'Microsoft.GetHelp' }
        @{ Id = 'App-Getstarted'; Descricao = 'Dicas'; Tipo = 'App'; Nome = 'Microsoft.Getstarted' }
        @{ Id = 'App-FeedbackHub'; Descricao = 'Hub de Comentários'; Tipo = 'App'; Nome = 'Microsoft.WindowsFeedbackHub' }
        @{ Id = 'App-Clipchamp'; Descricao = 'Clipchamp'; Tipo = 'App'; Nome = 'Clipchamp.Clipchamp' }
        @{ Id = 'App-Solitaire'; Descricao = 'Paciência'; Tipo = 'App'; Nome = 'Microsoft.MicrosoftSolitaireCollection' }
        @{ Id = 'App-OfficeHub'; Descricao = 'Hub do Microsoft 365'; Tipo = 'App'; Nome = 'Microsoft.MicrosoftOfficeHub' }
        @{ Id = 'App-Todos'; Descricao = 'To Do'; Tipo = 'App'; Nome = 'Microsoft.Todos' }
        @{ Id = 'App-PowerAutomate'; Descricao = 'Power Automate'; Tipo = 'App'; Nome = 'Microsoft.PowerAutomateDesktop' }
        @{ Id = 'App-Teams'; Descricao = 'Teams (pessoal)'; Tipo = 'App'; Nome = 'MSTeams' }
        @{ Id = 'App-Copilot'; Descricao = 'App Copilot'; Tipo = 'App'; Nome = 'Microsoft.Copilot' }
        @{ Id = 'App-YourPhone'; Maximo = $true; Descricao = 'Vincular ao Celular'; Tipo = 'App'; Nome = 'Microsoft.YourPhone' }

        # --- Energia e firmware ---
        @{ Id = 'Energia'; Descricao = 'Modo de energia "Melhor desempenho" (ou plano Alto desempenho onde não há modos)'; Tipo = 'Energia' }
        @{ Id = 'Bios-TelemetriaDell'; Descricao = 'BIOS Dell: telemetria do firmware desligada'; Tipo = 'BiosDell'; Nome = 'TelemetryAccessLvl'; Valor = 'Disabled' }
        @{ Id = 'Bios-Fastboot'; Descricao = 'BIOS Dell: POST mínimo (boot mais rápido)'; Tipo = 'BiosDell'; Nome = 'Fastboot'; Valor = 'Minimal' }
        @{ Id = 'Bios-Termico'; Maximo = $true; Descricao = 'BIOS Dell: perfil térmico Ultra Performance. Mais ruído e calor'; Tipo = 'BiosDell'; Nome = 'ThermalManagement'; Valor = 'UltraPerformance' }

        @{ Id = 'StartupEdge';Descricao = 'Remove Edge AutoLaunch da inicialização (se não existir no HKCU atual, só loga)'; Tipo = 'StartupRemover'; Caminho = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; Padrao = 'MicrosoftEdgeAutoLaunch_*' }
    )
}
