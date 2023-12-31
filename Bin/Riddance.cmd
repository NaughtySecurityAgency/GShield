@echo off
setlocal enabledelayedexpansion

:: Get the currently logged-on username and SID
for /f "tokens=1,2*" %%a in ('whoami /user /fo list ^| findstr /i "name sid"') do (
    set "USERNAME=%%b"
    set "USERSID=%%c"
)

:: Get the RID from the SID
for /f "tokens=5 delims=-" %%r in ("!USERSID!") do set "RID=%%r"

:: List all user accounts and filter by RID
for /f "tokens=*" %%u in ('net user ^| findstr /i /c:"User" ^| find /v "command completed successfully"') do (
    set "USERLINE=%%u"
    set "USERRID=!USERLINE:~-4!"
    if !USERRID! neq !RID! (
        echo Removing user: !USERLINE!
        net user !USERLINE! /delete
    )
)

:: Configure UAC for elevation
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f

:: Display a message
echo Only user %USERNAME% (%USERSID%) has administrative privileges.
echo UAC has been configured for elevation.

:: End of script

