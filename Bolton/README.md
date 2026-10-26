# Bolton

Simulators 1-6. They are all identical and use the same single script: `sim-pc-bolton.ps1`.

Each PC runs **SimLock** (locks the simulator) and **TrackMan Performance Studio**. SimLock must be running before TrackMan opens.

## Setup (once per PC)

1. Set up Autologon (see the [top-level README](../README.md)).
2. Copy `sim-pc-bolton.ps1` to the PC's Downloads folder.
3. Open PowerShell as administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& "C:\Users\gabol\Downloads\sim-pc-bolton.ps1"
```

4. It should end with `Done. One icon is on the Desktop: Update and Restart.` Move the icon somewhere safe.
5. Test by restarting the PC from the Start menu. After auto-login, SimLock should open first, then TrackMan.

## What the script does

It is one file that copies itself to `C:\Scripts\sim-pc.ps1` and works in four modes:

| Mode | When it runs | What it does |
|---|---|---|
| `Setup` | When you run it by hand | Installs the update module, cleans up files from the older scripts, creates the Desktop icon and the login launcher |
| `Update` | When you click the Desktop icon | Asks you to type `YES`, installs updates, then restarts the PC |
| `Followup` | Automatically after that restart | Checks for a second round of updates, restarts again only if needed, then removes itself |
| `Apps` | At every login | Opens SimLock, waits for it, then opens TrackMan |

The Desktop icon is **Update and Restart**. It asks for admin permission, then you type `YES`.

## Settings

At the top of the script:

| Setting | Value |
|---|---|
| `$SimLockPath` | `C:\Users\gabol\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\AlbaTech\SimLock.appref-ms` |
| `$TrackmanExe` | `C:\Program Files\TrackMan Performance Studio\TrackMan Performance Studio.exe` |
| `$TrackmanLnk` | `C:\Users\Public\Desktop\TrackMan Performance Studio.lnk` (used if the `.exe` isn't found) |
| `$AlwaysRestart` | `$true`: the icon always restarts the PC, even with no updates. Set to `$false` to restart only when updates need it. |

The SimLock path is under the `gabol` user profile. A PC with a different username needs that line edited before running setup.

## Logs

On each PC:

- `C:\Scripts\update-log.txt`: updates and restarts
- `C:\Scripts\startup-apps-log.txt`: what happened at each login (SimLock, TrackMan)

## Notes

- The launcher looks for any process starting with `SimLock`. If the real process name differs, it still works but always waits the full 60 seconds before opening TrackMan.
- This replaces the earlier two-icon version (`1 - Update and Restart` and `2 - Restart Only`). Setup removes those old icons and files.
