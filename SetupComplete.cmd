@echo off

:: Elevate
>nul 2>&1 fsutil dirty query %systemdrive% || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

:: Active Folder
pushd %~dp0
cd Bin
setlocal enabledelayedexpansion

:: Create restore point
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set datetime=%%a
set datetime=!datetime:~0,14!
set datetime=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2! !datetime:~8,2!:!datetime:~10,2!:!datetime:~12,2!
set restorePointDescription=AutoRestorePoint_!datetime!
wmic /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "%restorePointDescription%", 100, 7
echo Restore point created: %restorePointDescription%

:: Powershell
    for %%A in (*.ps1) do (
        @powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%A" -WindowStyle Hidden
)

:: Batch
for %%B in (*.cmd) do (
    call "%%B"
)

:: Registry
for %%C in (*.reg) do (
    reg import "%%C"
)
endlocal
