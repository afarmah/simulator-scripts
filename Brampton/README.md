# Brampton

Two types of simulators, so two scripts:

| Simulators | Software | Script | App opened at login |
|---|---|---|---|
| 1-4 | Uneekor | `setup-uneekor.ps1` | `C:\Uneekor\Launcher\UneekorLauncher.exe` |
| 5-8 | TrackMan | `setup-trackman.ps1` | `C:\Users\Public\Desktop\TrackMan Performance Studio.lnk` |

Don't run the Uneekor script on a TrackMan PC or the other way round. Each one adds its own app to the startup folder.

## Setup (once per PC)

1. Set up Autologon (see the [top-level README](../README.md)).
2. Copy the right script for that PC to its Downloads folder.
3. Open PowerShell as administrator and run (swap in the real username and script name):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& "C:\Users\<username>\Downloads\setup-uneekor.ps1"
```

4. It should end with `Uneekor will open after login.` (or `TrackMan will open after login.`) and `Done.`
5. Two shortcuts appear on the Desktop. Move them somewhere safe.
6. Test **2 - Restart Only** first. The PC should restart, sign itself in, and open the app.

## The two Desktop shortcuts

| Shortcut | What it does |
|---|---|
| **1 - Update and Restart** | Asks for admin permission, then you type `YES`. Installs Windows updates and restarts if needed. After the restart it checks silently for a second round of updates and restarts again only if needed. |
| **2 - Restart Only** | Restarts the PC after 30 seconds. To cancel, open Terminal and run `shutdown /a`. |

The update logic is saved on each PC as `C:\Scripts\update-now.ps1`, and the log is `C:\Scripts\update-log.txt`.

## Notes

- If a PC doesn't have the app at the expected path, the script warns you and still creates the shortcuts. Edit line 3 of the script and run it again.
- The TrackMan script copies the existing Public Desktop shortcut into the startup folder so TrackMan keeps its own settings.
- Usernames differ between PCs (seen so far: `almig`, `baygo`). Run `whoami` to check.
- Script names in this folder were shortened from the originals: `setup-shortcuts-uneekor.ps1` is now `setup-uneekor.ps1`, and `setup-shortcuts-trackman-lnk.ps1` is now `setup-trackman.ps1`.

## Not done yet

- Pressing a button inside the Uneekor app after it opens (needs the button name and a screenshot).
- Monday 3-4 AM automatic restart and update. The planned approach is a scheduled task that wakes the PC and runs the update script.
- Brampton has not been moved to the single-script format that Bolton uses.
