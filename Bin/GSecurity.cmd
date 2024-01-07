@echo off
setlocal enabledelayedexpansion

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

:: RAM Cleaner
md "%systemdrive%\Windows\Ram Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Ram Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Ram Cleaner\"
schtasks /create /xml "Ram Cleaner.xml" /tn "Ram Cleaner" /ru ""

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
for /f "tokens=*" %%a in ('whoami /user /fo csv ^| find "S-1"') do set CURRENT_SID=%%a
if not defined CURRENT_SID (
    echo Error: Unable to retrieve current user SID.
    exit /b 1
)
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!" /v "FeatureStates" /t REG_DWORD /d 0000013c /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH-SKYPE" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
Echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\FACEBOOK" /v "OptInStatus" /t REG_DWORD /d 00000000 /f

:: Antivirus
Start /wait "" catchme.exe

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