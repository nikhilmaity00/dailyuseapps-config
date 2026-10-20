# OnePlus Nord 5 (OxygenOS 16.0.1) Safe Debloat Suite

A non-destructive, 100% reversible debloat and memory optimization suite tailored specifically for the **OnePlus Nord 5** (`CPH2707`) running **OxygenOS 16.0.1** (ColorOS base).

## Overview & Philosophy
- **Safe & Non-Destructive**: Uses `pm disable-user --user 0`, strictly avoiding `pm uninstall`. All system APKs remain safely untouched on `/system` and `/product`.
- **100% Reversible**: Run `./restore.sh` at any time to immediately restore every package back to stock.
- **Strict Zero-Risk Guarantee**: After a deep-dive dependency re-check, all packages with ties to device stability, hardware charging, game detection, launcher gestures, or Google Assistant have been protected.
- **Preserved Apps & Features**:
  - **Games & Game Space**: `com.oplus.games`, `com.google.android.play.games`, and `com.oplus.cosa` (App Enhancement Service / game detection).
  - **Theme Store**: `com.oplus.themestore`.
  - **Digital Wellbeing**: `com.google.android.apps.wellbeing`.
  - **Always-On Display & Wise Charging**: `com.oplus.deepthinker`.
  - **Launcher Gestures**: `com.coloros.assistantscreen` (left screen) & `com.oppo.quicksearchbox` (swipe-down search).
  - **Google Productivity**: `com.google.android.googlequicksearchbox` (Assistant/Circle to Search), `gearhead` (Android Auto), and `as` (Smart text selection).
  - **Smart Sidebar**: `com.coloros.smartsidebar` (mirroring Samsung Edge Panels).
  - **Core OS Protections**: SystemUI, Launcher, Settings, InCallUI/Phone, Camera, Battery, Subsystems, and `com.coloros.weather.service`.

---

## Active Zero-Risk Packages (51 Packages Total)

| Group | Category | Count | Key Examples |
|---|---|:---:|---|
| **Group 1** | HeyTap & Ad Services | 8 | HeyTap Browser, Cloud, App Market, Push MCS, Lockscreen Glance Ads (Pictorial), HTMS OvAds |
| **Group 2** | Oplus Telemetry & Loggers | 14 | `statistics.rom` (User Experience Program), `crashbox`, `logkit`, `onetrace`, `dmp`, `sau` (silent app updater), `cota` |
| **Group 3** | Commercial Bloat & Preloads | 13 | OnePlus Store (Mall), Red Cable Club (Membership), Omoji, Pay, Secure Keyboard, Upgrade Guide, Facebook background services |
| **Group 4** | Auxiliary ColorOS Gimmicks | 5 | Children Space (Kid Mode), ColorOS Video Player (ad-heavy), OCR Scanner, User Manual, Rider Mode |
| **Group 5** | Google Background Stubs | 11 | Play crash feedback, Partner Setup, Wi-Fi printer recommendation poller, ARCore, System Tracing |

---

## Usage

### 1. Execute Debloat
Ensure USB debugging is enabled and your OnePlus phone is connected:
```bash
cd /Users/anish/oneplus_nord5_debloat
./debloat.sh
```

### 2. Verify Reclaimed Memory & Reboot
After running `debloat.sh`, reboot your device to flush lingering kernel cache:
```bash
adb reboot
```

### 3. Restore to Stock
To revert all changes and re-enable all packages:
```bash
cd /Users/anish/oneplus_nord5_debloat
./restore.sh
```
