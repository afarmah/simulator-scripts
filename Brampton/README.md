# Brampton

Two types of simulators, so two scripts. Both use the same single-script design as Bolton: one file, one Desktop icon (**Update and Restart**).

| Simulators | Software | Script | Opened at login |
|---|---|---|---|
| 1-4 | Uneekor | `sim-pc-brampton-uneekor.ps1` | SimLock (Uneekor loads on its own) |
| 5-8 | TrackMan | `sim-pc-brampton-trackman.ps1` | SimLock first, then TrackMan |

Don't run one script on the other type of PC.

## Setup (once per PC)

1. Set up Autologon (see the [top-level README](../README.md)).
2. Copy the right script for that PC to its Downloads folder.
3. Open PowerShell as administrator, click inside the window, and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& (Get-ChildItem C:\Users\*\Downloads\sim-pc-brampton-trackman*.ps1)[0].FullName
```

Use `sim-pc-brampton-uneekor*.ps1` instead on simulators 1-4. The command finds the file in any user's Downloads folder, so no username is needed.

4. It should end with `Done. One icon is on the Desktop: Update and Restart.` Move the icon somewhere safe.
5. Test by restarting the PC from the Start menu. After auto-login, the apps should open (see the table above).

## What the scripts do

Each one copies itself to `C:\Scripts\sim-pc.ps1` and works in four modes:

| Mode | When it runs | What it does |
|---|---|---|
| `Setup` | When you run it by hand | Installs the update module, cleans up files from the older scripts, creates the Desktop icon and the login launcher |
| `Update` | When you click the Desktop icon | Asks you to type `YES`, installs updates, then restarts the PC |
| `Followup` | Automatically after that restart | Checks for a second round of updates, restarts again only if needed, then removes itself |
| `Apps` | At every login | Uneekor PCs: opens SimLock. TrackMan PCs: opens SimLock, waits for it, then opens TrackMan |

## Settings

At the top of each script:

| Setting | Value |
|---|---|
| `$SimLockPath` | `%APPDATA%\Microsoft\Windows\Start Menu\Programs\AlbaTech\SimLock.appref-ms` for whichever user is logged in, so no edit is needed for a different username. If it isn't there, the script searches the Start Menu for `SimLock*.appref-ms`. |
| `$TrackmanExe` (TrackMan script) | `C:\Program Files\TrackMan Performance Studio\TrackMan Performance Studio.exe` |
| `$TrackmanLnk` (TrackMan script) | `C:\Users\Public\Desktop\TrackMan Performance Studio.lnk`, used only if the `.exe` isn't found |
| `$AlwaysRestart` | `$true`: the icon always restarts the PC, even with no updates. Set to `$false` to restart only when updates need it. |

## Logs

On each PC:

- `C:\Scripts\update-log.txt`: updates and restarts
- `C:\Scripts\startup-apps-log.txt`: what happened at each login

## Notes

- These replace the earlier two-icon versions (`1 - Update and Restart` and `2 - Restart Only`). Setup removes those icons and the old files.
- Uneekor PCs: if an older script put an Uneekor shortcut in the startup folder, setup leaves it alone.
- TrackMan PCs: setup removes the old direct TrackMan startup shortcut, because the launcher now opens it after SimLock.
- The launcher looks for any process starting with `SimLock`. If the real name differs, it still works but always waits the full 60 seconds before opening TrackMan.
- Usernames differ between PCs (seen so far: `almig`, `baygo`). Run `whoami` to check.

## Not done yet

- Pressing a button inside the Uneekor app after it opens (needs the button name and a screenshot).
- Monday 3-4 AM automatic restart and update. The planned approach is a scheduled task that wakes the PC and runs the update script.
