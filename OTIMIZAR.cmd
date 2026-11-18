@echo off
rem Lançador: duplo clique. Pede elevação e chama executar.ps1 / reverter.ps1.
chcp 65001 >nul
net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"
echo.
echo  OTIMIZAR_WINDOWS
echo  [1] Simular (não altera nada)
echo  [2] Otimizar - seguro (sem perda de função)
echo  [3] Otimizar - máximo (desliga busca indexada, localização etc.)
echo  [4] Reverter tudo
echo  [5] Sair
echo.
rem set antes do choice: em .cmd, um set bem-sucedido zera o errorlevel
set PS=powershell -NoProfile -ExecutionPolicy Bypass -File
choice /c 12345 /n /m "Escolha: "
if errorlevel 5 exit /b
if errorlevel 4 (%PS% "%~dp0reverter.ps1" & goto fim)
rem Etapas 0145 = diagnóstico, backup, ajustes, manutenção. Limpeza e reparo: rode executar.ps1 completo.
if errorlevel 3 (%PS% "%~dp0executar.ps1" -Etapas 0145 -Maximo & goto fim)
if errorlevel 2 (%PS% "%~dp0executar.ps1" -Etapas 0145 & goto fim)
%PS% "%~dp0executar.ps1" -Etapas 0145 -Maximo -WhatIf
:fim
echo.
echo  Terminado. Reinicie o computador para tudo valer. Logs em "%~dp0logs".
pause
