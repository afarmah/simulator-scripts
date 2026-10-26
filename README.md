# Simulator Scripts

Setup scripts and notes for the Windows PCs that run the golf simulators at Golf Almighty.

| Folder | Simulators | Software | Script |
|---|---|---|---|
| [`Bolton/`](Bolton/) | 1-6 (all identical) | SimLock + TrackMan | `sim-pc-bolton.ps1` |
| [`Brampton/`](Brampton/) | 1-4 | Uneekor + SimLock | `sim-pc-brampton-uneekor.ps1` |
| [`Brampton/`](Brampton/) | 5-8 | TrackMan | `setup-trackman.ps1` |

Each folder has its own README with the setup steps for that location.

## What the scripts do

1. Install the `PSWindowsUpdate` PowerShell module.
2. Create a Desktop icon that installs Windows updates and restarts the PC.
3. Open the simulator software automatically after the PC signs itself in.

## Needed on every PC

- **Autologon** (Microsoft Sysinternals): https://learn.microsoft.com/en-us/sysinternals/downloads/autologon
  Run `Autologon64.exe` as administrator, check the username and domain (run `whoami` if unsure), enter the Windows password, and click **Enable**. Without it the PC stops at the sign-in screen after a restart and the apps don't open.
- **PowerShell as administrator.** The window title must say **Administrator**.
- Sleep turned off, or wake timers enabled, if the PC is left asleep overnight.

## Running a script

In an administrator PowerShell window (swap in the real folder and username):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& "C:\Users\<username>\Downloads\<script-name>.ps1"
```

The execution policy change only lasts for that window. Use quotes around the path if the file name has a space.

## Notes

- Each PC is separate, so run the script once on every one.
- Usernames differ between PCs. Run `whoami` to see the right one.
- Nothing in this repo contains passwords. Autologon stores the password on the PC itself.
