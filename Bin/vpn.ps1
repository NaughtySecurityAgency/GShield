# Variables
$openVpnInstallerUrl = "https://swupdate.openvpn.org/community/releases/openvpn-install-2.5.6-I601.exe"
$openVpnInstaller = "openvpn-install-2.5.6-I601.exe"
$openVpnConfigUrl = "https://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip"
$openVpnConfigFile = "VPNBook.com-OpenVPN-Euro1.ovpn"
$passwordFilePath = "credentials.txt"
$startupShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ConnectVPN.lnk"

# Download and install OpenVPN
Invoke-WebRequest -Uri $openVpnInstallerUrl -OutFile $openVpnInstaller
Start-Process -Wait -FilePath $openVpnInstaller

# Download VPNBook configuration file
Invoke-WebRequest -Uri $openVpnConfigUrl -OutFile $openVpnConfigFile

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

# Run OpenVPN with the configuration file
Start-Process -FilePath "C:\Program Files\OpenVPN\bin\openvpn.exe" -ArgumentList "--config", $openVpnConfigFile

# Create a shortcut to start the VPN on startup
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($startupShortcut)
$Shortcut.TargetPath = "C:\Program Files\OpenVPN\bin\openvpn.exe"
$Shortcut.Arguments = "--config $openVpnConfigFile"
$Shortcut.Save()

# Clean up temporary files
Remove-Item $openVpnInstaller
