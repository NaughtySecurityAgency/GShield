@echo off
setlocal enabledelayedexpansion
:: DHT
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v SavedLegacySettings /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxySettingsPerUser /f
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\IPSec\Policy\Local" /f
Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\IPSec\Policy\Local" /f
bitsadmin /reset /allusers
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /f /reg:32
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /f /reg:64
Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v DisableConfig /t REG_DWORD /d 0 /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v DisableSR /t REG_DWORD /d 0 /f
Reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
Reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend /f /v Start /t REG_DWORD /d 0x00000002
Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 0x00000000
Reg add "HKLM\SYSTEM\CurrentControlSet\services\MpsSvc" /V Start /T REG_DWORD /D 2 /F
Reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f /v EnableFirewall /t REG_DWORD /d 0x00000001
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f /v DoNotAllowExceptions
Reg add "HKLM\SYSTEM\CurrentControlSet\services\wuauserv" /V Start /T REG_DWORD /D 2 /F
Reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v NoWindowsUpdate
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\services\wscsvc" /V Start /T REG_DWORD /D 2 /F
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v HideSCAHealth /t REG_SZ /d 0
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v HideSCAHealth /t REG_SZ /d 0
:: Autopilot
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverInstall\Restrictions" /v "AllowUserDeviceClasses" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "2" /f
:: Default user
net user defaultuser1 /delete
net user defaultuser100000 /delete
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
:: Netbios
rd /s /q "%SystemDrive%\Program Files\Common Files"@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"
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
takeown /f "%SystemDrive%\Users\Public\Desktop" /r /d y
icacls "%SystemDrive%\Users\Public\Desktop" /inheritance:r
icacls "%SystemDrive%\Users\Public\Desktop" /grant:r "%username%:F" /t /l /q /c
takeown /f "%USERPROFILE%\Desktop" /r /d y
icacls "%USERPROFILE%\Desktop" /inheritance:r
icacls "%USERPROFILE%\Desktop" /grant:r "%username%:F" /t /l /q /c
:: RAM Cleaner
md "%systemdrive%\Windows\Ram Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Ram Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Ram Cleaner\"
schtasks /create /xml "Ram Cleaner.xml" /tn "Ram Cleaner" /ru ""
:: Riddance
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
:: Perf
wmic recoveros set WriteToSystemLog = False
wmic recoveros set SendAdminAlert = False
wmic recoveros set AutoReboot = False
wmic recoveros set DebugInfoType = 0
:: Wifi
REM Get current user SID
for /f "tokens=*" %%a in ('whoami /user /fo csv ^| find "S-1"') do set CURRENT_SID=%%a

REM Check if SID retrieval was successful
if not defined CURRENT_SID (
    echo Error: Unable to retrieve current user SID.
    exit /b 1
)

REM Set the registry values with the current user SID
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!" /v "FeatureStates" /t REG_DWORD /d 0000013c /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH-SKYPE" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\FACEBOOK" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
:: Password Updater Service
md %windir%\PasswordUpdaterService
    for %%F in ("PasswordUpdaterService.*") do (
        copy /y "%%F" %windir%\PasswordUpdaterService\
)
sc create PasswordUpdaterService binpath= %windir%\PasswordUpdaterService\PasswordUpdaterService.exe
sc config PasswordUpdaterService start= auto
:: Lgpo
Lgpo /g "%~dp0"