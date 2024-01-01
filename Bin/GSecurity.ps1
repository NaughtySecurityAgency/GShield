# Consider alternative methods for getting installed programs
# For example, using registry entries or other reliable methods

# Iterate through Chromium browsers
foreach ($browser in $chromiumBrowsers) {
    Write-Output "Found Chromium browser: $($browser.Name)"

    # Path to the preferences file may vary
    $prefsPath = Join-Path $browser.InstallLocation 'User Data\Default\Preferences'

    if (Test-Path $prefsPath) {
        try {
            # Load existing preferences
            $prefs = Get-Content $prefsPath -Raw | ConvertFrom-Json

            # Modify preferences to block WebRTC and Chrome Remote Desktop
            $prefs.webrtc.ip_handling_policy = "disable_non_proxied_udp"
            $prefs.RemoteAccessHost.client = $false

            # Save modified preferences
            $prefs | ConvertTo-Json | Set-Content $prefsPath

            Write-Host "Successfully modified preferences for $browser.Name" -ForegroundColor Green
        } catch {
            Write-Host "Failed to modify preferences for $browser.Name. Error: $_" -ForegroundColor Red
        }
    }
}

# Deny NETWORK access on all fixed drives
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

# Configure DNS settings
try {
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest "https://scripttiger.github.io/alts/compressed/blacklist-fg.txt" -OutFile "C:\Windows\System32\drivers\etc\hosts"
    ipconfig /flushdns
    reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t "REG_DWORD" /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t "REG_DWORD" /d "1" /f

    Write-Host "DNS settings configured successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to configure DNS settings. Error: $_" -ForegroundColor Red
}
