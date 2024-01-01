:: Active folder
pushd %~dp0

:Cleaner
emptystandbylist.exe workingsets
emptystandbylist.exe modifiedpagelist
Reg.exe delete "HKLM\software\policies\microsoft\windows\currentversion\internet settings\lockdown_zones\0" /f
Reg.exe delete "HKLM\software\policies\microsoft\windows\currentversion\internet settings\lockdown_zones\1" /f
Reg.exe delete "HKLM\software\policies\microsoft\windows\currentversion\internet settings\lockdown_zones\2" /f
Reg.exe delete "HKLM\software\policies\microsoft\windows\currentversion\internet settings\lockdown_zones\3" /f
Reg.exe delete "HKLM\software\policies\microsoft\windows\currentversion\internet settings\lockdown_zones\4" /f
timeout /t 10 /nobreak > NUL
goto:Cleaner