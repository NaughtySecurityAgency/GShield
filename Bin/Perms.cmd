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
