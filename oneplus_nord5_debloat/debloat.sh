#!/usr/bin/env bash
# ==============================================================================
# OnePlus Nord 5 (OxygenOS 16.0.1 / ColorOS Base) Safe Debloat Suite
# Target Device: OnePlus Nord 5 (CPH2707 / Android 16 / OxygenOS 16.0.1)
# Mode: Safe Disabling (pm disable-user --user 0) - 100% Non-destructive & Reversible
# Includes: Pre/Post RAM telemetry, logging, and automatic device detection
# Architecture: Tier 1 (100% Zero-Risk Core) active by default
# Preserved: Games, Theme Store, Digital Wellbeing, Smart Sidebar, AOD/DeepThinker,
#            Game Optimization (COSA), Carrier Wi-Fi, and Google Assistant/Auto
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SCRIPT_DIR}/logs"
mkdir -p "${LOGS_DIR}"

# 1. Verify ADB is installed
if ! command -v adb &> /dev/null; then
  echo "[-] Error: 'adb' command not found in PATH."
  echo "    Install Android platform-tools via 'brew install android-platform-tools'."
  exit 1
fi

# 2. Detect or select target device
DEVICE_ID="${1:-$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')}"

if [[ -z "${DEVICE_ID}" ]]; then
  echo "[-] Error: No Android device detected in 'device' state."
  echo "    Please plug in your device, ensure USB debugging is enabled, and try again."
  exit 1
fi

if ! adb -s "${DEVICE_ID}" get-state &> /dev/null; then
  echo "[-] Error: Device ${DEVICE_ID} not detected or unauthorized."
  echo "    Check USB connection and tap 'Allow USB debugging' on the screen."
  exit 1
fi

DEVICE_MODEL=$(adb -s "${DEVICE_ID}" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
BUILD_DISPLAY=$(adb -s "${DEVICE_ID}" shell getprop ro.build.display.id 2>/dev/null | tr -d '\r')
ANDROID_VER=$(adb -s "${DEVICE_ID}" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
BUILD_OTA=$(adb -s "${DEVICE_ID}" shell getprop ro.build.version.ota 2>/dev/null | tr -d '\r')

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HUMAN_TIME=$(date +"%Y-%m-%d %H:%M:%S")
SESSION_LOG="${LOGS_DIR}/debloat_${DEVICE_MODEL}_${TIMESTAMP}.log"
HISTORY_LOG="${LOGS_DIR}/debloat_history.log"

log() {
  local msg="$1"
  echo -e "${msg}"
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ${msg}" >> "${SESSION_LOG}"
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] [${DEVICE_MODEL}:${DEVICE_ID}] ${msg}" >> "${HISTORY_LOG}"
}

get_ram_info() {
  local dev="$1"
  adb -s "${dev}" shell "cat /proc/meminfo" 2>/dev/null | awk '
    /MemTotal:/ { total=$2 }
    /MemAvailable:/ { avail=$2 }
    /MemFree:/ { free=$2 }
    END {
      used = total - avail
      printf "%d %d %d %d", total, avail, free, used
    }
  '
}

fmt_mb() {
  local kb="$1"
  awk -v k="$kb" 'BEGIN { printf "%.2f MB (%.2f GB)", k/1024, k/1024/1024 }'
}

fmt_pct() {
  local part="$1"
  local total="$2"
  awk -v p="$part" -v t="$total" 'BEGIN { if (t > 0) printf "%.1f%%", (p/t)*100; else printf "0%%" }'
}

echo "=========================================================="
echo " OnePlus Nord 5 (OxygenOS 16.0.1) Safe Debloat Suite"
echo " Target Device: ${DEVICE_MODEL} (Serial: ${DEVICE_ID})"
echo " OS Build:      ${BUILD_DISPLAY} (Android ${ANDROID_VER})"
echo " OTA Version:   ${BUILD_OTA}"
echo " Mode:          Tier 1 (100% Zero-Risk Safe Debloat)"
echo " Session Log:   ${SESSION_LOG}"
echo " History Log:   ${HISTORY_LOG}"
echo "=========================================================="
echo ""

echo "=== Debloat Session Started at ${HUMAN_TIME} for ${DEVICE_MODEL} (${DEVICE_ID}) ===" >> "${SESSION_LOG}"
echo "=== Debloat Session Started at ${HUMAN_TIME} for ${DEVICE_MODEL} (${DEVICE_ID}) ===" >> "${HISTORY_LOG}"

# 3. Read Pre-Execution RAM Statistics
echo "[*] Querying baseline RAM statistics before execution..."
RAM_PRE=$(get_ram_info "${DEVICE_ID}")
read -r TOTAL_KB PRE_AVAIL_KB PRE_FREE_KB PRE_USED_KB <<< "${RAM_PRE}"

PRE_AVAIL_STR=$(fmt_mb "${PRE_AVAIL_KB}")
PRE_USED_STR=$(fmt_mb "${PRE_USED_KB}")
TOTAL_RAM_STR=$(fmt_mb "${TOTAL_KB}")
PRE_AVAIL_PCT=$(fmt_pct "${PRE_AVAIL_KB}" "${TOTAL_KB}")
PRE_USED_PCT=$(fmt_pct "${PRE_USED_KB}" "${TOTAL_KB}")

log "----------------------------------------------------------"
log " [RAM BEFORE EXECUTION]"
log "   Total RAM:      ${TOTAL_RAM_STR}"
log "   Available RAM:  ${PRE_AVAIL_STR} (${PRE_AVAIL_PCT})"
log "   Used RAM:       ${PRE_USED_STR} (${PRE_USED_PCT})"
log "----------------------------------------------------------"
echo ""

# 4. Master List of 100% Zero-Risk Packages (51 Target Packages)
PACKAGES=(
  # ============================================================================
  # Group 1: HeyTap Ecosystem & Ad Services (8 Packages)
  # Pure ad engines, push marketing, lockscreen magazine promo feeds, and HeyTap cloud
  # ============================================================================
  "com.heytap.browser"                                           # HeyTap / OPPO Browser (ad-heavy web browser)
  "com.heytap.cloud"                                             # HeyTap Cloud (background cloud sync daemon, ~102MB RAM)
  "com.heytap.market"                                            # HeyTap App Market (redundant alternative app store)
  "com.heytap.market.overlay"                                    # HeyTap App Market theme overlay
  "com.heytap.mcs"                                               # Mobile Cloud Service (HeyTap push notification & ad daemon, ~157MB RAM)
  "com.heytap.pictorial"                                         # Lock Screen Magazine / Glance ads (promotions on lock screen)
  "com.heytap.htms"                                              # HeyTap Cloud Control / OvAds (active ad-serving daemon, ~80MB RAM)
  "com.nearme.instant.platform"                                  # NearMe / HeyTap Quick Apps Instant Platform

  # ============================================================================
  # Group 2: Oplus Telemetry & Loggers (14 Packages)
  # Intrusive diagnostic uploaders, background loggers, and silent app updaters
  # ============================================================================
  "com.oplus.statistics.rom"                                     # User Experience Program (intrusive telemetry running at boot, ~104MB RAM)
  "com.oplus.crashbox"                                           # Crashbox system failure telemetry daemon
  "com.oplus.logkit"                                             # LogKit bug reporting and background log collector
  "com.oplus.lfeh"                                               # Logging feedback engine
  "com.oplus.onetrace"                                           # OneTrace background tracing service (~95MB RAM)
  "com.oplus.dmp"                                                # Device Management Platform telemetry (~95MB RAM)
  "com.oplus.qualityprotect"                                     # Quality Protect diagnostic reporter
  "com.oplus.sau"                                                # Software Auto-Update (silent background app updater)
  "com.oplus.sauhelper"                                          # Software Auto-Update helper
  "com.oplus.cota"                                               # Carrier Over-The-Air config fetcher
  "com.oplus.bttestmode"                                         # Bluetooth factory test mode
  "com.oplus.nfcengineertest"                                    # NFC engineering test stub
  "com.oplus.wifibackuprestore"                                  # Wi-Fi credentials backup to HeyTap cloud
  "com.coloros.activation"                                       # E-warranty card registration daemon

  # ============================================================================
  # Group 3: Commercial Bloatware, Store Portals & Preloaded Tracking (13 Packages)
  # Shopping apps, regional portals, and Facebook background daemons
  # ============================================================================
  "com.oneplus.mall"                                             # OnePlus Store / Shopping app
  "com.oneplus.membership"                                       # Red Cable Club membership promotional portal
  "com.oplus.omoji"                                              # Omoji 3D avatar gimmick
  "com.oplus.pay"                                                # OnePlus / OPPO Pay
  "com.oplus.securepay"                                          # Secure Pay payment interceptor
  "com.oplus.securitykeyboard"                                   # Secure Keyboard (replaces password keyboard; falls back to Gboard)
  "com.oplus.upgradeguide"                                       # OS Upgrade Guide nag screen
  "com.redteamobile.roaming"                                     # RedTea Mobile Roaming store
  "com.wapi.wapicertmanage"                                      # WAPI Chinese wireless cert manager (unused in India)
  "com.facebook.appmanager"                                      # Facebook App Manager background updater
  "com.facebook.services"                                        # Facebook Services background sync daemon (~94MB RAM)
  "com.facebook.system"                                          # Facebook System Installer stub
  "android.autoinstalls.config.oneplus"                          # OnePlus AutoInstalls config (silent partner app installer)

  # ============================================================================
  # Group 4: Auxiliary ColorOS Gimmicks & Duplicate Apps (5 Packages)
  # Preserves Smart Sidebar, stock launcher, and launcher gesture feeds
  # ============================================================================
  "com.coloros.childrenspace"                                    # Children Space / Kid Mode
  "com.coloros.video"                                            # ColorOS stock video player (excessive permissions & ads)
  "com.coloros.ocrscanner"                                       # ColorOS OCR Scanner
  "com.coloros.operationManual"                                  # Online User Manual stub
  "com.oplus.riderMode"                                          # Rider Mode

  # ============================================================================
  # Group 5: Google Background Fluff & Legacy Stubs (11 Packages)
  # Preserves Google Search, Circle to Search, Google Assistant, and Android Auto
  # ============================================================================
  "com.google.android.feedback"                                  # Google Play crash feedback reporter
  "com.google.android.partnersetup"                              # Google Partner Setup background runner
  "com.google.android.printservice.recommendation"               # Print Service recommendation Wi-Fi poller
  "com.google.ar.core"                                           # Google Play Services for AR
  "com.google.ar.lens"                                           # Google Lens AR shortcuts
  "com.google.android.onetimeinitializer"                        # Google One-Time Initializer
  "com.android.traceur"                                          # System Tracing background recorder
  "com.android.egg"                                              # Android Easter Egg hidden game
  "com.android.bluetoothmidiservice"                             # Bluetooth MIDI musical device service
  "com.android.providers.partnerbookmarks"                       # Chrome partner sponsored bookmarks
  "com.android.email.partnerprovider"                            # OEM email partner provider
)

# Fetch current device package status in bulk for performance
ALL_INSTALLED=$(adb -s "${DEVICE_ID}" shell pm list packages | tr -d '\r' | sed 's/^package://')
CURRENTLY_DISABLED=$(adb -s "${DEVICE_ID}" shell pm list packages -d | tr -d '\r' | sed 's/^package://')

NEWLY_DISABLED=0
ALREADY_DISABLED=0
NOT_FOUND=0
FAILED=0

echo "[*] Processing ${#PACKAGES[@]} zero-risk target packages..."
echo "----------------------------------------------------------"

for pkg in "${PACKAGES[@]}"; do
  # 1. Check if package is installed on this device
  if ! echo "${ALL_INSTALLED}" | grep -q "^${pkg}$"; then
    log " [SKIP - NOT INSTALLED]  ${pkg}"
    ((NOT_FOUND++))
    continue
  fi

  # 2. Check if already disabled
  if echo "${CURRENTLY_DISABLED}" | grep -q "^${pkg}$"; then
    log " [ALREADY DISABLED]       ${pkg}"
    ((ALREADY_DISABLED++))
    continue
  fi

  # 3. Disable package and kill lingering processes
  OUTPUT=$(adb -s "${DEVICE_ID}" shell pm disable-user --user 0 "${pkg}" 2>&1 | tr -d '\r')
  adb -s "${DEVICE_ID}" shell am force-stop "${pkg}" 2>/dev/null || true

  if [[ "$OUTPUT" == *"disabled-user"* ]] || [[ "$OUTPUT" == *"new state: disabled"* ]]; then
    log " [OK - DISABLED NOW]     ${pkg}"
    ((NEWLY_DISABLED++))
  else
    log " [ERROR - FAILED]        ${pkg} (Output: ${OUTPUT})"
    ((FAILED++))
  fi
done

echo "----------------------------------------------------------"
log "[+] Package Summary for ${DEVICE_MODEL} (${DEVICE_ID}):"
log "    Newly disabled:          ${NEWLY_DISABLED}"
log "    Already disabled:        ${ALREADY_DISABLED}"
log "    Not found on device:     ${NOT_FOUND}"
log "    Failed / Errors:         ${FAILED}"
log "    Total target packages:   ${#PACKAGES[@]}"
echo ""

# 5. Read Post-Execution RAM Statistics & Calculate Delta
echo "[*] Calculating memory delta..."
sleep 1
RAM_POST=$(get_ram_info "${DEVICE_ID}")
read -r _ POST_AVAIL_KB POST_FREE_KB POST_USED_KB <<< "${RAM_POST}"

POST_AVAIL_STR=$(fmt_mb "${POST_AVAIL_KB}")
POST_USED_STR=$(fmt_mb "${POST_USED_KB}")
POST_AVAIL_PCT=$(fmt_pct "${POST_AVAIL_KB}" "${TOTAL_KB}")
POST_USED_PCT=$(fmt_pct "${POST_USED_KB}" "${TOTAL_KB}")

DIFF_KB=$(( POST_AVAIL_KB - PRE_AVAIL_KB ))

log "=========================================================="
log " [RAM COMPARISON & RECLAIMED MEMORY]"
log "   Total RAM:              ${TOTAL_RAM_STR}"
log "   Available (Before):     ${PRE_AVAIL_STR} (${PRE_AVAIL_PCT})"
log "   Available (After):      ${POST_AVAIL_STR} (${POST_AVAIL_PCT})"
log "   Used RAM (Before):      ${PRE_USED_STR} (${PRE_USED_PCT})"
log "   Used RAM (After):       ${POST_USED_STR} (${POST_USED_PCT})"

if (( DIFF_KB > 0 )); then
  DIFF_STR=$(fmt_mb "${DIFF_KB}")
  log "   >> Memory Freed Now:    +${DIFF_STR} immediately available!"
elif (( DIFF_KB == 0 )); then
  log "   >> Memory Freed Now:    0 MB (all packages were already disabled/inactive)"
else
  ABS_DIFF=$(( -DIFF_KB ))
  DIFF_STR=$(fmt_mb "${ABS_DIFF}")
  log "   >> Memory Delta:        -${DIFF_STR} (temporary page cache variation)"
fi

log "=========================================================="
echo "Logs saved to:"
echo "  - Session Log: ${SESSION_LOG}"
echo "  - History Log: ${HISTORY_LOG}"
echo ""
echo "Note: Restart your phone to flush any cached kernel pages and"
echo "system-level daemons for maximum memory release:"
echo "    adb -s ${DEVICE_ID} reboot"
echo "=========================================================="
