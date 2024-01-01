# Get the list of installed programs
$installedPrograms = Get-WmiObject -Query "SELECT * FROM Win32_Product"

# Filter for Chromium browsers
$chromiumBrowsers = $installedPrograms | Where-Object { $_.Name -like "*Chromium*" }

foreach ($browser in $chromiumBrowsers) {
    Write-Output "Found Chromium browser: $($browser.Name)"

    # Path to the preferences file may vary
    $prefsPath = Join-Path $browser.InstallLocation 'User Data\Default\Preferences'

    if (Test-Path $prefsPath) {
        # Load existing preferences
        $prefs = Get-Content $prefsPath | ConvertFrom-Json

        # Modify preferences to block WebRTC and Chrome Remote Desktop
        $prefs.webrtc.ip_handling_policy = "disable_non_proxied_udp"
        $prefs.RemoteAccessHost.client = $false

        # Save modified preferences
        $prefs | ConvertTo-Json | Set-Content $prefsPath
    }
}

# Get all fixed drives
$drives = Get-Volume

foreach ($drive in $drives) {
    $drivePath = $drive.Path
    try {
        # Get current ACL
        $acl = Get-Acl -Path $drivePath

        # Create NETWORK SID and DENY rule
        $networkSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::NetworkSid, $null)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($networkSid, "FullControl", "ContainerInherit, ObjectInherit", "None", "Deny")

        # Add DENY rule to the current ACL
        $acl.AddAccessRule($accessRule)

        # Apply the new ACL
        Set-Acl -Path $drivePath -AclObject $acl

        Write-Host "Successfully denied NETWORK access to $drivePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to deny NETWORK access on $drivePath. Error: $_" -ForegroundColor Red
    }
}
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest "https://scripttiger.github.io/alts/compressed/blacklist-fg.txt" -OutFile "C:\Windows\System32\drivers\etc\hosts"
ipconfig /flushdns
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t "REG_DWORD" /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t "REG_DWORD" /d "1" /f

# Variables
$openVpnInstallerUrl = "https://swupdate.openvpn.org/community/releases/OpenVPN-2.6.8-I001-amd64.msi"
$openVpnInstaller = "OpenVPN-2.6.8-I001-amd64.msi"
$openVpnConfigUrl = "https://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip"
$openVpnConfigFile = "VPNBook.com-OpenVPN-Euro1.ovpn"
$passwordFilePath = "credentials.txt"
$startupShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ConnectVPN.lnk"
$openVpnConfigDirectory = "C:\Program Files\OpenVPN\config"  # Update this with the correct path

# Download and install OpenVPN
Invoke-WebRequest -Uri $openVpnInstallerUrl -OutFile $openVpnInstaller
Start-Process -Wait -FilePath msiexec -ArgumentList "/i", $openVpnInstaller, "/quiet", "/qn", "/norestart"

# Download VPNBook configuration file
Invoke-WebRequest -Uri $openVpnConfigUrl -OutFile $openVpnConfigFile

# Copy the configuration file to the OpenVPN config directory
Copy-Item -Path $openVpnConfigFile -Destination $openVpnConfigDirectory

# Check for a new password on VPNBook website
$newPassword = (Invoke-WebRequest -Uri "https://www.vpnbook.com/freevpn" | Select-String -Pattern 'Password: (.+)' | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()

# Read the existing password from the file
$existingPassword = Get-Content -Path $passwordFilePath -Raw

# If the password has changed, update the configuration file
if ($newPassword -ne $existingPassword) {
    # Replace username and password in the configuration file
    (Get-Content -Path $openVpnConfigFile) -replace "auth-user-pass", "auth-user-pass credentials.txt" | Set-Content -Path $openVpnConfigFile
    "vpnbook`n$newPassword" | Out-File -FilePath $passwordFilePath -Encoding UTF8 -NoNewline
}


