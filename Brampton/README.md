# Brampton

Two types of simulators, so two scripts:

| Simulators | Software | Script | Opened at login |
|---|---|---|---|
| 1-4 | Uneekor | `sim-pc-brampton-uneekor.ps1` | SimLock (Uneekor loads on its own) |
| 5-8 | TrackMan | `setup-trackman.ps1` | `C:\Users\Public\Desktop\TrackMan Performance Studio.lnk` |

Don't run one script on the other type of PC.

## Simulators 1-4 (Uneekor): `sim-pc-brampton-uneekor.ps1`

One file, one Desktop icon (**Update and Restart**). Same design as the Bolton script, but it opens SimLock only. Uneekor is not launched by the script, because it loads automatically after a restart.

### Setup (once per PC)

1. Set up Autologon (see the [top-level README](../README.md)).
2. Copy the script to the PC's Downloads folder.
3. Open PowerShell as administrator and run (swap in the real username):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& "C:\Users\<username>\Downloads\sim-pc-brampton-uneekor.ps1"
```

4. It should end with `Done. One icon is on the Desktop: Update and Restart.` Move the icon somewhere safe.
5. Test by restarting the PC from the Start menu. After auto-login, Uneekor should load and SimLock should open.

### What the script does

It copies itself to `C:\Scripts\sim-pc.ps1` and works in four modes:

| Mode | When it runs | What it does |
|---|---|---|
| `Setup` | When you run it by hand | Installs the update module, cleans up files from the older scripts, creates the Desktop icon and the login launcher |
| `Update` | When you click the Desktop icon | Asks you to type `YES`, installs updates, then restarts the PC |
| `Followup` | Automatically after that restart | Checks for a second round of updates, restarts again only if needed, then removes itself |
| `Apps` | At every login | Opens SimLock |

### Settings

At the top of the script:

| Setting | Value |
|---|---|
| `$SimLockPath` | `%APPDATA%\Microsoft\Windows\Start Menu\Programs\AlbaTech\SimLock.appref-ms` for whichever user is logged in, so no edit is needed for a different username. If it isn't there, the script searches the Start Menu for `SimLock*.appref-ms`. |
| `$AlwaysRestart` | `$true`: the icon always restarts the PC, even with no updates. Set to `$false` to restart only when updates need it. |

### Logs

- `C:\Scripts\update-log.txt`: updates and restarts
- `C:\Scripts\startup-apps-log.txt`: what happened at each login

### Notes

- This replaces the earlier two-icon version (`1 - Update and Restart` and `2 - Restart Only`). Setup removes those icons and the old files.
- If an older script put an Uneekor shortcut in the startup folder, setup leaves it alone.
- SimLock is assumed to be installed the same way as at Bolton (an `AlbaTech` entry in the Start Menu). Check this on the first PC.

## Simulators 5-8 (TrackMan): `setup-trackman.ps1`

Two Desktop shortcuts and the update logic saved as `C:\Scripts\update-now.ps1`.

### Setup (once per PC)

1. Set up Autologon.
2. Copy the script to the PC's Downloads folder.
3. Open PowerShell as administrator and run (swap in the real username):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& "C:\Users\<username>\Downloads\setup-trackman.ps1"
```

4. It should end with `TrackMan will open after login.` and `Done.`
5. Test **2 - Restart Only** first. The PC should restart, sign itself in, and open TrackMan.

### The two Desktop shortcuts

| Shortcut | What it does |
|---|---|
| **1 - Update and Restart** | Asks for admin permission, then you type `YES`. Installs Windows updates and restarts if needed. After the restart it checks silently for a second round of updates and restarts again only if needed. |
| **2 - Restart Only** | Restarts the PC after 30 seconds. To cancel, open Terminal and run `shutdown /a`. |

The log is `C:\Scripts\update-log.txt`. The script copies the existing Public Desktop TrackMan shortcut into the startup folder so TrackMan keeps its own settings. If the shortcut isn't at that path, edit line 3 and run it again.

## Notes

- Usernames differ between PCs (seen so far: `almig`, `baygo`). Run `whoami` to check.
- The TrackMan script was shortened from `setup-shortcuts-trackman-lnk.ps1`.

## Not done yet

- Pressing a button inside the Uneekor app after it opens (needs the button name and a screenshot).
- Monday 3-4 AM automatic restart and update. The planned approach is a scheduled task that wakes the PC and runs the update script.
- Simulators 5-8 are not yet moved to the single-script format.
