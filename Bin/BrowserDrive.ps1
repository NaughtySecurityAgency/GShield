# Define the keyword to search for in the display name
$ChromiumKeyword = "chromium"
$FirefoxKeyword = "firefox"

# Get all installed applications with names containing the keyword
$InstalledBrowsers = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                     Where-Object { $_.DisplayName -like "*$ChromiumKeyword*" -or $_.DisplayName -like "*$FirefoxKeyword*" }

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

# Move Chromium-based browsers cache to RAM drive
$ChromiumCachePaths = Get-ChildItem -Path "$env:LOCALAPPDATA\*\User Data\Default\Cache" -Directory
foreach ($ChromiumCachePath in $ChromiumCachePaths) {
    Move-Item -Path $ChromiumCachePath.FullName -Destination $RAMDrivePath -Force
    cmd /c mklink /D $ChromiumCachePath.FullName $RAMDrivePath
}

# Move Mozilla Firefox cache to RAM drive
$FirefoxCachPath = "$env:APPDATA\Mozilla\Firefox\Profiles\*.default\cache2"
Move-Item -Path $FirefoxCachPath -Destination $RAMDrivePath -Force
cmd /c mklink /D $FirefoxCachPath $RAMDrivePath

Write-Host "Dynamic RAM drive setup complete."
