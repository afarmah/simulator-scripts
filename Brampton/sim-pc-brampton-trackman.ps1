param([ValidateSet("Setup","Update","Followup","Apps")]$Mode = "Setup")

# ===== Brampton TrackMan simulators (5-8) =====
# SimLock path is built from whichever user is logged in, so it works on any username.
$SimLockPath   = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\AlbaTech\SimLock.appref-ms"
$TrackmanExe   = "C:\Program Files\TrackMan Performance Studio\TrackMan Performance Studio.exe"
$TrackmanLnk   = "C:\Users\Public\Desktop\TrackMan Performance Studio.lnk"   # used only if the .exe isn't found
$AlwaysRestart = $true   # $true = the icon always restarts the PC, even with no updates
# ==============================================

$ScriptPath   = "C:\Scripts\sim-pc.ps1"
$FollowupTask = "Update Followup"

function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-Shortcut($path, $target, $argString, $admin) {
    $s = (New-Object -ComObject WScript.Shell).CreateShortcut($path)
    $s.TargetPath = $target
    $s.Arguments = $argString
    if (Test-Path $target) { $s.WorkingDirectory = Split-Path $target }
    $s.Save()
    if ($admin) {
        $b = [IO.File]::ReadAllBytes($path)
        $b[0x15] = $b[0x15] -bor 0x20
        [IO.File]::WriteAllBytes($path, $b)
    }
}

function Register-Followup {
    if (-not (Get-ScheduledTask $FollowupTask -ErrorAction SilentlyContinue)) {
        Register-ScheduledTask -TaskName $FollowupTask `
          -Principal (New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest) `
          -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath -Mode Followup") `
          -Trigger (New-ScheduledTaskTrigger -AtStartup) | Out-Null
    }
}

# Uses the path above if it exists, otherwise searches the Start Menu for SimLock
function Find-SimLock {
    if (Test-Path $SimLockPath) { return $SimLockPath }
    $roots = @("$env:APPDATA\Microsoft\Windows\Start Menu\Programs", "$env:ProgramData\Microsoft\Windows\Start Menu\Programs")
    foreach ($r in $roots) {
        $f = Get-ChildItem $r -Recurse -Filter "SimLock*.appref-ms" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($f) { return $f.FullName }
    }
    return $null
}

switch ($Mode) {

    # ---------- Run once per computer: installs everything ----------
    "Setup" {
        if (-not (Test-Admin)) {
            Write-Warning "Open PowerShell as administrator, then run this script again."
            return
        }
        $ErrorActionPreference = "Stop"
        New-Item -ItemType Directory -Force -Path C:\Scripts | Out-Null
        if ($PSCommandPath -and ($PSCommandPath -ne $ScriptPath)) {
            Copy-Item $PSCommandPath $ScriptPath -Force
        }

        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module PSWindowsUpdate -Force

        # Clean up files and shortcuts from the older scripts
        Unregister-ScheduledTask $FollowupTask -Confirm:$false -ErrorAction SilentlyContinue
        Remove-Item C:\Scripts\update-now.ps1, C:\Scripts\startup-apps.ps1 -Force -ErrorAction SilentlyContinue

        $desktop = [Environment]::GetFolderPath('Desktop')
        $startup = [Environment]::GetFolderPath('Startup')
        foreach ($old in @("1 - Update and Restart.lnk", "2 - Restart Only.lnk")) {
            Remove-Item "$desktop\$old" -Force -ErrorAction SilentlyContinue
        }
        foreach ($old in @("Trackman.lnk", "TrackMan Performance Studio.lnk")) {
            Remove-Item "$startup\$old" -Force -ErrorAction SilentlyContinue
        }

        # The one icon (runs as administrator)
        New-Shortcut "$desktop\Update and Restart.lnk" "powershell.exe" `
          "-ExecutionPolicy Bypass -File `"$ScriptPath`" -Mode Update" $true

        # Login launcher (SimLock first, then TrackMan)
        New-Shortcut "$startup\Start Sim Apps.lnk" "powershell.exe" `
          "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" -Mode Apps" $false

        if (-not (Find-SimLock)) { Write-Warning "SimLock not found. Check that it is installed for this user." }
        if (-not ((Test-Path $TrackmanExe) -or (Test-Path $TrackmanLnk))) { Write-Warning "TrackMan not found. Check the paths at the top of this script." }

        Write-Host "Done. One icon is on the Desktop: Update and Restart. Move it somewhere safe."
    }

    # ---------- The icon: updates, then restarts ----------
    "Update" {
        $a = Read-Host "Type YES to install updates and restart"
        if ($a -ne "YES") { return }
        Start-Transcript -Path C:\Scripts\update-log.txt -Append
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
        $needsReboot = Get-WURebootStatus -Silent
        if ($AlwaysRestart -or $needsReboot) {
            Register-Followup
            Stop-Transcript
            Restart-Computer -Force
        } else {
            Stop-Transcript
        }
    }

    # ---------- Runs by itself after the restart: catches a second round ----------
    "Followup" {
        Start-Transcript -Path C:\Scripts\update-log.txt -Append
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
        if (Get-WURebootStatus -Silent) {
            Stop-Transcript
            Restart-Computer -Force
        } else {
            Unregister-ScheduledTask $FollowupTask -Confirm:$false -ErrorAction SilentlyContinue
            Stop-Transcript
        }
    }

    # ---------- Runs at every login: SimLock first, then TrackMan ----------
    "Apps" {
        Start-Transcript -Path C:\Scripts\startup-apps-log.txt -Append
        $simlock = Find-SimLock
        if ($simlock) {
            Write-Host "Starting SimLock: $simlock"
            Start-Process $simlock
            for ($i = 0; $i -lt 60; $i++) {
                if (Get-Process -Name "SimLock*" -ErrorAction SilentlyContinue) { break }
                Start-Sleep -Seconds 1
            }
            Start-Sleep -Seconds 10
        } else {
            Write-Host "SimLock not found"
        }

        if (Test-Path $TrackmanExe)     { Write-Host "Starting TrackMan (exe)"; Start-Process $TrackmanExe }
        elseif (Test-Path $TrackmanLnk) { Write-Host "Starting TrackMan (shortcut)"; Start-Process $TrackmanLnk }
        else                            { Write-Host "TrackMan not found" }
        Stop-Transcript
    }
}
