# OTIMIZAR_WINDOWS

Scripts PowerShell (Windows PowerShell 5.1, sem dependências) que diagnosticam, fazem backup, limpam, reparam e otimizam um Windows 10/11 de forma reversível. Feito para o Dell Latitude 3420, mas roda em qualquer PC: o que não existir na máquina é ignorado.

## Como rodar

Duplo clique em **`OTIMIZAR.cmd`** (pede elevação e mostra um menu: simular, seguro, máximo, reverter).

Ou, em um PowerShell **como administrador**:

```powershell
.\executar.ps1                         # etapas 00 a 05 (o reparo leva horas)
.\executar.ps1 -Etapas 0145            # diagnóstico, backup, ajustes, manutenção
.\executar.ps1 -Etapas 0145 -Maximo    # inclui ajustes com perda de função
.\executar.ps1 -WhatIf                 # simula, sem alterar nada
.\reverter.ps1                         # desfaz tudo a partir de estado\estado.json
.\reverter.ps1 -Id Svc-WSearch         # desfaz só um ajuste
```

Testes: `powershell -NoProfile -File tests\Comum.Tests.ps1`

## O que é ajustado

Tudo está em `config\ajustes.psd1`, uma linha por ajuste. Tipos: `Registro`, `StartupRemover`, `Servico`, `Tarefa`, `App`, `Energia`, `BiosDell`. Itens com `Maximo = $true` só rodam com `-Maximo`.

A explicação de cada grupo, as fontes e o que não foi incluído (e por quê) estão em [`OTIMIZACAO_MAXIMA.md`](OTIMIZACAO_MAXIMA.md).
