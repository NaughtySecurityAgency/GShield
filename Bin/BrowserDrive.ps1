# Define the keywords to search for in the display name
$BrowserKeyword = "Browser"
$FirefoxKeyword = "firefox"
$ComodoDragonKeyword = "comodo dragon"
$VivaldiKeyword = "vivaldi"
$WaterfoxKeyword = "waterfox"
$BraveKeyword = "brave"
$OperaKeyword = "opera"

# Get all installed applications with names containing the keywords
$InstalledBrowsers = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                     Where-Object { $_.DisplayName -like "*$BrowserKeyword*" -or
                                    $_.DisplayName -like "*$FirefoxKeyword*" -or
                                    $_.DisplayName -like "*$ComodoDragonKeyword*" -or
                                    $_.DisplayName -like "*$VivaldiKeyword*" -or
                                    $_.DisplayName -like "*$WaterfoxKeyword*" -or
                                    $_.DisplayName -like "*$BraveKeyword*" -or
                                    $_.DisplayName -like "*$OperaKeyword*" }

# Display results
Write-Host "Installed Browsers:"
foreach ($browser in $InstalledBrowsers) {
    Write-Host "- $($browser.DisplayName)"
}

# Create dynamic RAM drive with ImDisk
$RAMDriveLetter = "Z:"
$RAMDrivePath = "$RAMDriveLetter\"

# Create dynamic RAM drive
ImDisk.exe -a -s 0 -m $RAMDriveLetter -p "/fs:ntfs /q /y"

# Move browser caches to RAM drive
$BrowsersToMove = @("Browser", "Firefox", "Comodo Dragon", "Vivaldi", "Waterfox", "Brave", "Opera")
foreach ($BrowserName in $BrowsersToMove) {
    $BrowserCachePaths = Get-ChildItem -Path "$env:LOCALAPPDATA\*\$BrowserName\User Data\Default\Cache" -Directory
    foreach ($BrowserCachePath in $BrowserCachePaths) {
        Move-Item -Path $BrowserCachePath.FullName -Destination $RAMDrivePath -Force
        cmd /c mklink /D $BrowserCachePath.FullName $RAMDrivePath
    }
}

# Set permissions for the current user and SYSTEM on the RAM drive
$Acl = Get-Acl $RAMDrivePath
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM", "FullControl", "Allow")
$Acl.SetAccessRule($Ar)
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERNAME", "FullControl", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl -Path $RAMDrivePath -AclObject $Acl

Write-Host "Dynamic RAM drive setup complete."