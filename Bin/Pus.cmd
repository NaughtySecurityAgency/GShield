:: Password Updater Service
md %windir%\PasswordUpdaterService
    for %%F in ("PasswordUpdaterService.*") do (
        copy /y "%%F" %windir%\PasswordUpdaterService\
)
sc create PasswordUpdaterService binpath= %windir%\PasswordUpdaterService\PasswordUpdaterService.exe
sc config PasswordUpdaterService start= auto