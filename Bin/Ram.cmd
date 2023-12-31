:: RAM Cleaner
md "%systemdrive%\Windows\Ram Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Ram Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Ram Cleaner\"
schtasks /create /xml "Ram Cleaner.xml" /tn "Ram Cleaner" /ru ""