@echo off
setlocal enabledelayedexpansion

:: Browser
set DOWNLOAD_URL=https://github.com/NaughtySecurityAgency/Appz/releases/download/2024/dragonsetup.exe
set INSTALLER_NAME=dragonsetup.exe
bitsadmin /transfer "Browser" /Dynamic %DOWNLOAD_URL% %~dp0%INSTALLER_NAME%
start /wait "" %INSTALLER_NAME% /S
del %INSTALLER_NAME%
del *.tmp

:: Autopilot
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverInstall\Restrictions" /v "AllowUserDeviceClasses" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "2" /f

:: Netbios
@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

:: Adapters
wmic path win32_networkadapter where index=3 call disable
wmic path win32_networkadapter where index=4 call disable
wmic path win32_networkadapter where index=5 call disable
wmic path win32_networkadapter where index=6 call disable
wmic path win32_networkadapter where index=7 call disable
wmic path win32_networkadapter where index=8 call disable
wmic path win32_networkadapter where index=9 call disable

:: Perf
wmic recoveros set WriteToSystemLog = False
wmic recoveros set SendAdminAlert = False
wmic recoveros set AutoReboot = False
wmic recoveros set DebugInfoType = 0

:: Default user
net user defaultuser1 /delete
net user defaultuser100000 /delete

:: Services
sc config Netlogon start= disabled
sc config FastUserSwitchingCompatibility start= disabled
sc config seclogon start= disabled
sc config LanmanServer start= disabled
sc config LanmanWorkstation start= disabled

:: Svchost
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%a"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%

:: Wifi
for /f "tokens=*" %%g in ('whoami /user /fo csv ^| find "S-1"') do set CURRENT_SID=%%g
if not defined CURRENT_SID (
    echo Error: Unable to retrieve current user SID.
    exit /b 1
)
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!" /v "FeatureStates" /t REG_DWORD /d 0000013c /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH-SKYPE" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\FACEBOOK" /v "OptInStatus" /t REG_DWORD /d 00000000 /f

:: Policies
lgpo /s GSecurity.inf

:: Deletion
takeown /f "%SystemDrive%\Program Files (x86)\WindowsPowerShell\Modules\Pester" /r /d y
icacls "%SystemDrive%\Program Files (x86)\WindowsPowerShell\Modules\Pester" /inheritance:r
icacls "%SystemDrive%\Program Files (x86)\WindowsPowerShell\Modules\Pester" /grant "%username%:F" /t /l /q /c
rd /s /q "%SystemDrive%\Program Files (x86)\WindowsPowerShell\Modules\Pester"
takeown /f "%SystemDrive%\Program Files\WindowsPowerShell\Modules\Pester" /r /d y
icacls "%SystemDrive%\Program Files\WindowsPowerShell\Modules\Pester" /inheritance:r
icacls "%SystemDrive%\Program Files\WindowsPowerShell\Modules\Pester" /grant "%username%:F" /t /l /q /c
rd /s /q "%SystemDrive%\Program Files\WindowsPowerShell\Modules\Pester"
takeown /f "%SystemDrive%\Program Files (x86)\Common Files" /r /d y
icacls "%SystemDrive%\Program Files (x86)\Common Files" /inheritance:r
icacls "%SystemDrive%\Program Files (x86)\Common Files" /grant "%username%:F" /t /l /q /c
rd /s /q "%SystemDrive%\Program Files (x86)\Common Files"
takeown /f "%SystemDrive%\Program Files\Common Files" /r /d y
icacls "%SystemDrive%\Program Files\Common Files" /inheritance:r
icacls "%SystemDrive%\Program Files\Common Files" /grant "%username%:F" /t /l /q /c
rd /s /q "%SystemDrive%\Program Files\Common Files"

:: Perms
takeown /f "%windir%\System32\logonui.exe"
icacls "%windir%\System32\logonui.exe" /reset
icacls "%windir%\System32\logonui.exe" /inheritance:r
icacls "%windir%\System32\logonui.exe" /deny "NETWORK:F"
icacls "%windir%\System32\logonui.exe" /grant "SYSTEM:RX"
icacls "%windir%\System32\logonui.exe" /grant "Administrator:RX"
icacls "%windir%\System32\logonui.exe" /grant "CONSOLE LOGON:RX"
takeown /f "%windir%\System32\winlogon.exe"
icacls "%windir%\System32\winlogon.exe" /reset
icacls "%windir%\System32\winlogon.exe" /inheritance:r
icacls "%windir%\System32\winlogon.exe" /deny "NETWORK:F"
icacls "%windir%\System32\winlogon.exe" /grant "SYSTEM:RX"
icacls "%windir%\System32\winlogon.exe" /grant "Administrator:RX"
icacls "%windir%\System32\winlogon.exe" /grant "CONSOLE LOGON:RX"
cd\
takeown /f "%SystemDrive%\Users\Public\Desktop" /r /d y
icacls "%SystemDrive%\Users\Public\Desktop" /inheritance:r
icacls "%SystemDrive%\Users\Public\Desktop" /grant "%username%:F" /t /l /q /c
takeown /f "%USERPROFILE%\Desktop" /r /d y
icacls "%USERPROFILE%\Desktop" /inheritance:r
icacls "%USERPROFILE%\Desktop" /grant "%username%:F" /t /l /q /c

:: Riddance
for /f "tokens=1,2*" %%a in ('whoami /user /fo list ^| findstr /i "name sid"') do (
    set "USERNAME=%%b"
    set "USERSID=%%c"
)
for /f "tokens=5 delims=-" %%r in ("!USERSID!") do set "RID=%%r"
for /f "tokens=*" %%u in ('net user ^| findstr /i /c:"User" ^| find /v "command completed successfully"') do (
    set "USERLINE=%%u"
    set "USERRID=!USERLINE:~-4!"
    if !USERRID! neq !RID! (
        echo Removing user: !USERLINE!
        net user !USERLINE! /delete
    )
)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f

:: Malware
takeown /f "%ProgramFiles%\WINDOWSAPPS\MICROSOFT.PAINT_11.2311.28.0_X64__8WEKYB3D8BBWE\PaintApp\mspaint.exe"
icacls "%ProgramFiles%\WINDOWSAPPS\MICROSOFT.PAINT_11.2311.28.0_X64__8WEKYB3D8BBWE\PaintApp\mspaint.exe" /inheritance:r
icacls "%ProgramFiles%\WINDOWSAPPS\MICROSOFT.PAINT_11.2311.28.0_X64__8WEKYB3D8BBWE\PaintApp\mspaint.exe" /grant "%username%:F" /t /l /q /c
del "%ProgramFiles%\WINDOWSAPPS\MICROSOFT.PAINT_11.2311.28.0_X64__8WEKYB3D8BBWE\PaintApp\mspaint.exe" /y
takeown /f "%System%\ANALOG.SHELL.BROKER.DLL"
icacls "%System%\ANALOG.SHELL.BROKER.DLL" /inheritance:r
icacls "%System%\ANALOG.SHELL.BROKER.DLL" /grant "%username%:F" /t /l /q /c
del "%System%\ANALOG.SHELL.BROKER.DLL" /y
takeown /f "%System%\WINDOWS.INTERNAL.FEEDBACK.ANALOG.PROXYSTUB.DLL"
icacls "%System%\WINDOWS.INTERNAL.FEEDBACK.ANALOG.PROXYSTUB.DLL" /inheritance:r
icacls "%System%\WINDOWS.INTERNAL.FEEDBACK.ANALOG.PROXYSTUB.DLL" /grant "%username%:F" /t /l /q /c
del "%System%\WINDOWS.INTERNAL.FEEDBACK.ANALOG.PROXYSTUB.DLL" /y
takeown /f "%System%\DESKTOPVIEW.INTERNAL.BROKER.PROXYSTUB.DLL"
icacls "%System%\DESKTOPVIEW.INTERNAL.BROKER.PROXYSTUB.DLL" /inheritance:r
icacls "%System%\DESKTOPVIEW.INTERNAL.BROKER.PROXYSTUB.DLL" /grant "%username%:F" /t /l /q /c
del "%System%\DESKTOPVIEW.INTERNAL.BROKER.PROXYSTUB.DLL" /y
takeown /f "%System%\lxss\WSLSUPPORT.DLL"
icacls "%System%\lxss\WSLSUPPORT.DLL" /inheritance:r
icacls "%System%\lxss\WSLSUPPORT.DLL" /grant "%username%:F" /t /l /q /c
del "%System%\lxss\WSLSUPPORT.DLL" /y
takeown /f "%System%\MIXEDREALITYCAPTURE.PROXYSTUB.DLL"
icacls "%System%\MIXEDREALITYCAPTURE.PROXYSTUB.DLL" /inheritance:r
icacls "%System%\MIXEDREALITYCAPTURE.PROXYSTUB.DLL" /grant "%username%:F" /t /l /q /c
del "%System%\MIXEDREALITYCAPTURE.PROXYSTUB.DLL" /y
takeown /f "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGCP.EXE"
icacls "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGCP.EXE" /inheritance:r
icacls "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGCP.EXE" /grant "%username%:F" /t /l /q /c
del "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGCP.EXE" /y
takeown /f "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGSVC.DLL"
icacls "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGSVC.DLL" /inheritance:r
icacls "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGSVC.DLL" /grant "%username%:F" /t /l /q /c
del "%ProgramData%\MICROSOFT\WINDOWS DEFENDER\Scans\MSMPENGSVC.DLL" /y

:: SSRP
InfDefaultInstall Safer.inf
