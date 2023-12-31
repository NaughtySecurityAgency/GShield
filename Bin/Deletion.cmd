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