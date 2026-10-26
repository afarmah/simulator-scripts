#Requires -RunAsAdministrator
# ===== EDIT THIS LINE if the Uneekor path is different on a computer =====
$AppPath = "C:\Uneekor\Launcher\UneekorLauncher.exe"
# =========================================================================

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path C:\Scripts | Out-Null

# --- Update module ---
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module PSWindowsUpdate -Force

# --- Script 1: updates + restart if needed ---
$update = @'
param([switch]$Manual)
if ($Manual) {
    $a = Read-Host "Type YES to install updates and restart if needed"
    if ($a -ne "YES") { exit }
}
Start-Transcript -Path C:\Scripts\update-log.txt -Append
$task = "Update Followup"
Import-Module PSWindowsUpdate
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
if (Get-WURebootStatus -Silent) {
    if (-not (Get-ScheduledTask $task -ErrorAction SilentlyContinue)) {
        Register-ScheduledTask -TaskName $task `
          -Principal (New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest) `
          -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\update-now.ps1") `
          -Trigger (New-ScheduledTaskTrigger -AtStartup)
    }
    Stop-Transcript
    Restart-Computer -Force
} else {
    Unregister-ScheduledTask $task -Confirm:$false -ErrorAction SilentlyContinue
    Stop-Transcript
}
'@
Set-Content -Path C:\Scripts\update-now.ps1 -Value $update

# --- Helper to make a shortcut ---
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

$desktop = [Environment]::GetFolderPath('Desktop')
$startup = [Environment]::GetFolderPath('Startup')

# --- Shortcut 1: Update + restart if needed ---
New-Shortcut "$desktop\1 - Update and Restart.lnk" "powershell.exe" `
  '-ExecutionPolicy Bypass -File "C:\Scripts\update-now.ps1" -Manual' $true

# --- Shortcut 2: Restart only (30 second delay; cancel with: shutdown /a) ---
New-Shortcut "$desktop\2 - Restart Only.lnk" "shutdown.exe" `
  '/r /t 30 /c "Restarting in 30 seconds. To cancel, open Terminal and run: shutdown /a"' $false

# --- Open Uneekor at every login ---
if (Test-Path $AppPath) {
    New-Shortcut "$startup\Uneekor.lnk" $AppPath "" $false
    Write-Host "Uneekor will open after login."
} else {
    Write-Warning "Uneekor path not found. Edit line 3 of this script and run it again."
}

Write-Host "Done. Two shortcuts are on the Desktop. Move them somewhere safe."
