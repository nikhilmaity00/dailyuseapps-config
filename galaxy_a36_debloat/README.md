# Universal Samsung One UI Debloat Suite (Galaxy A36 & S21 FE)

A safe, non-destructive, and 100% reversible debloat suite for Samsung One UI devices (Galaxy A36, Galaxy S21 FE, and other modern One UI phones).

## Features
- **Real-Time RAM Telemetry**: Measures and displays Total, Available, and Used RAM before and after execution, showing the exact memory reclaimed.
- **84 Master Target Packages**:
  * Core lag daemons (GOS CPU/GPU throttling, Rubin Customization, Bixby wake listeners)
  * Heavy Google daemons (~400MB+ RAM: Google App search widget, System Intelligence)
  * Samsung background diagnostics and hidden loggers (DiagMonAgent, Location Provider 2, SPP Push)
  * Factory hardware test harnesses and secret dialers (*#0*#, SysDump, WLAN test, camera test)
  * Obsolete carrier provisioning protocols (OMA-CP binary SMS, NSDS, Call+)
  * Unused foreign language TTS voice packs (German, French, Spanish, Russian, Thai, etc. - keeps English and Hindi)
  * Android legacy fluff (Easter egg, Daydream screensaver, Bluetooth MIDI, OK Google voice enrollment)
- **Explicit Safe Exclusions (Preserved & Enabled)**:
  * **Edge Panels** (`clipboardedge`, `taskedge`, `quicktool`)
  * **Secure Folder** (`securefolder`)
  * **Samsung Reminder** (`reminder`)
  * **One-Handed Mode** (`easyonehand`)
  * **Dual Messenger** (`daagent`)
- **Dynamic Device Detection**: Automatically detects the connected Samsung phone via `adb`, or accepts a specific device serial.
- **Audit Logging**: Records every run with timestamped per-session logs and a cumulative history log in `logs/`.

---

## Scripts

### 1. `debloat.sh`
Disables all target packages safely via `pm disable-user --user 0`, terminates active lingering processes via `am force-stop`, and computes memory freed.
```bash
cd /Users/anish/galaxy_a36_debloat
./debloat.sh
```
*(To run on a specific device if multiple are connected, pass the serial: `./debloat.sh <device-serial>`)*

After running, reboot the phone to flush any cached kernel pages and dormant daemons:
```bash
adb reboot
```

### 2. `restore.sh`
Re-enables all 84 managed packages via `pm enable` and logs RAM state before and after restoration.
```bash
cd /Users/anish/galaxy_a36_debloat
./restore.sh
```

---

## Logs Directory
All operations and RAM metrics are tracked in:
- `logs/debloat_<model>_<timestamp>.log`: Detailed per-session log.
- `logs/debloat_history.log`: Continuous master history log across devices.
