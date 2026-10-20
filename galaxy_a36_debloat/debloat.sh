#!/usr/bin/env bash
# ==============================================================================
# Universal Samsung One UI Debloat Suite (Galaxy A36 & S21 FE Compatible)
# Mode: Safe Disabling (pm disable-user --user 0) - 100% Non-destructive & Reversible
# Includes: Pre/Post RAM telemetry, logging, and automatic device detection
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
ONEUI_VER=$(adb -s "${DEVICE_ID}" shell getprop ro.build.version.oneui 2>/dev/null | tr -d '\r')
ANDROID_VER=$(adb -s "${DEVICE_ID}" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')

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
echo " Samsung One UI Safe Debloat Suite"
echo " Target Device: ${DEVICE_MODEL} (Serial: ${DEVICE_ID})"
echo " Android:       ${ANDROID_VER} (One UI code: ${ONEUI_VER})"
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

# 4. Master List of Tailored Packages (84 Packages across 14 Functional Sections)
PACKAGES=(
  # === Section 1: Core Lag Culprits, Telemetry & CPU Throttling ===
  "com.samsung.android.game.gos"                                # Game Optimizing Service (thermal/GPU throttle daemon)
  "com.samsung.android.game.gamehome"                           # Gaming Hub / Game Launcher
  "com.samsung.android.app.spage"                               # Samsung Free (news feed panel)
  "com.samsung.slsi.telephony.silentlogging"                    # Exynos Modem Silent Logging
  "com.samsung.android.rubin.app"                               # Samsung Customization Service (activity & location profiling)
  "com.samsung.attribution"                                     # Samsung Attribution (ad conversion tracking)
  "com.samsung.oda.service"                                     # Samsung On-Device Ads (contextual ads in stock apps)
  "com.samsung.mfcontents"                                      # Samsung Media Promotion (promotional popups)
  "com.mygalaxy.service"                                        # My Galaxy Service (marketing push notifications)
  "com.samsung.android.beaconmanager"                           # Beacon Manager (continuous background BLE scanner)
  "com.hiya.star"                                               # Hiya Service (caller lookup telemetry)

  # === Section 2: Zero-Risk Background Diagnostics & Hidden Loggers ===
  "com.sec.android.diagmonagent"                                # Diagnostic Monitoring Agent (~96 MB RAM)
  "com.sec.location.nsflp2"                                     # Samsung Network Location Provider 2 (~87 MB RAM)
  "com.sec.spp.push"                                            # Samsung Push Service (~92 MB RAM)
  "com.samsung.android.knox.analytics.uploader"                 # Knox Analytics telemetry uploader
  "com.samsung.aasaservice"                                     # AASA Security Service (background CPU spikes)
  "com.sec.imslogger"                                           # IMS Logger (debug VoLTE/IMS logging)

  # === Section 3: Heavy Google Background Memory Eaters ===
  "com.google.android.googlequicksearchbox"                     # Google App & Search widget (~246 MB RAM)
  "com.google.android.as"                                       # Android System Intelligence (~103 MB RAM)
  "com.google.android.apps.turbo"                               # Device Health Services (Google battery polling)
  "com.google.ar.core"                                          # Google ARCore (AR tracking)
  "com.google.android.printservice.recommendation"              # Print Service Recommendation (Wi-Fi printer polling)

  # === Section 4: Samsung Cloud, Smart Switch & Multi-Device Sync ===
  "com.samsung.android.scloud"                                  # Samsung Cloud (Gallery/Notes sync)
  "com.sec.android.easyMover"                                   # Samsung Smart Switch Mobile
  "com.sec.android.easyMover.Agent"                             # Smart Switch Agent
  "com.microsoft.appmanager"                                    # Link to Windows / Your Phone Companion
  "com.samsung.android.mdx"                                     # Link to Windows Service / MDE Service Framework
  "com.samsung.android.mdecservice"                             # Samsung Call & Text on Other Devices

  # === Section 5: Redundant Password Vault (Excludes Secure Folder) ===
  "com.samsung.android.samsungpass"                             # Samsung Pass (redundant with Proton Pass)
  "com.samsung.android.samsungpassautofill"                     # Samsung Pass Autofill

  # === Section 6: Gallery Background Story Service (Excludes Edge Panels) ===
  "com.samsung.storyservice"                                    # Samsung Story Service (auto-generates gallery stories)

  # === Section 7: Bixby Suite (Always-On Listeners) ===
  "com.samsung.android.bixby.wakeup"                            # Bixby Voice Wakeup (audio hotword listener)
  "com.samsung.android.bixbyvision.framework"                   # Bixby Vision Framework (camera analysis engine)

  # === Section 8: AR, Avatar & Camera Extras ===
  "com.samsung.android.aremojieditor"                           # AR Emoji Editor
  "com.snap.camerakit.plugin.v1"                                # Snapchat Fun Mode Camera Plugin
  "com.samsung.android.app.camera.sticker.facearavatar.preload" # Camera Avatar Preload
  "com.samsung.android.stickercenter"                           # Samsung Sticker Center

  # === Section 9: Marketing & Partner Preloads ===
  "com.samsung.android.kidsinstaller"                           # Samsung Kids Installer
  "com.samsung.android.app.parentalcare"                        # Parental Care Service
  "com.facebook.services"                                       # Facebook Services background daemon
  "com.facebook.appmanager"                                     # Facebook App Manager
  "com.facebook.system"                                         # Facebook System Installer
  "android.autoinstalls.config.samsung"                         # Samsung AutoInstalls

  # === Section 10: Wearables & Wallet Services ===
  "com.samsung.accessory.budsunitemgr"                          # Galaxy Buds Manager
  "com.samsung.android.spayfw"                                  # Samsung Pay Framework

  # === Section 11: Factory Diagnostics & Secret Test Tools ===
  "com.sec.android.app.hwmoduletest"                            # HwModuleTest (*#0*# secret dialer menu)
  "com.sec.android.app.servicemodeapp"                          # SysDump Service Mode
  "com.sec.android.app.wlantest"                                # WLAN Engineering Test
  "com.sec.android.app.factorykeystring"                        # DeviceKeyString test app
  "com.sec.factory.camera"                                      # Camera Factory Test (*#34971539#)
  "com.sec.factory.cameralyzer"                                 # Cameralyzer factory tool
  "com.sem.factoryapp"                                          # SEMFactoryApp manufacturing test
  "com.sec.epdgtestapp"                                         # ePDG Wi-Fi calling test app
  "com.sec.modem.settings"                                      # Modem Settings & SilentLog
  "com.sec.android.RilServiceModeApp"                           # RIL Service Mode app
  "com.sec.phone"                                               # SecPhone test harness
  "com.samsung.ipservice"                                       # IP Service band selector
  "com.sec.android.app.parser"                                  # DRParser Mode

  # === Section 12: Obsolete Carrier Provisioning & Stubs ===
  "com.wsomacp"                                                 # OMA Client Provisioning (legacy binary SMS)
  "com.sec.vsim.ericssonnsds.webapp"                            # Ericsson NSDS WebApp
  "com.sec.bcservice"                                           # Carrier Cell Broadcast Service
  "com.samsung.crane"                                           # Vodafone/Carrier Call+ legacy feature
  "com.samsung.android.smartcallprovider"                       # Smart Call Provider

  # === Section 13: Unused Foreign TTS Voice Packs (Preserves English & Hindi) ===
  "com.samsung.SMT.lang_de_de_f00"                              # German (Germany) voice data
  "com.samsung.SMT.lang_fr_fr_f00"                              # French (France) voice data
  "com.samsung.SMT.lang_it_it_f00"                              # Italian (Italy) voice data
  "com.samsung.SMT.lang_es_es_f00"                              # Spanish (Spain) voice data
  "com.samsung.SMT.lang_es_us_f00"                              # Spanish (US) voice data
  "com.samsung.SMT.lang_pt_br_f00"                              # Portuguese (Brazil) voice data
  "com.samsung.SMT.lang_ru_ru_f00"                              # Russian voice data
  "com.samsung.SMT.lang_th_th_f00"                              # Thai voice data
  "com.samsung.SMT.lang_vi_vn_f00"                              # Vietnamese voice data
  "com.samsung.SMT.lang_id_id_f00"                              # Indonesian voice data
  "com.samsung.SMT.lang_pl_pl_f00"                              # Polish voice data

  # === Section 14: Android & Google Legacy Fluff ===
  "com.android.egg"                                             # Android Easter Egg hidden game
  "com.android.dreams.phototable"                               # Photo Table screensaver
  "com.android.bluetoothmidiservice"                            # Bluetooth MIDI musical device service
  "com.android.calllogbackup"                                   # AOSP Call Log Backup stub
  "com.android.providers.partnerbookmarks"                      # Chrome Partner sponsored bookmarks
  "com.android.hotwordenrollment.okgoogle"                      # OK Google voice enrollment model
  "com.android.hotwordenrollment.xgoogle"                       # XGoogle voice enrollment model
  "com.google.android.onetimeinitializer"                       # One-Time Initializer
  "com.google.android.partnersetup"                             # Google Partner Setup
  "com.google.android.feedback"                                 # Play Store Crash Feedback dialog
)

# Fetch current device package status in bulk for performance
ALL_INSTALLED=$(adb -s "${DEVICE_ID}" shell pm list packages | tr -d '\r' | sed 's/^package://')
CURRENTLY_DISABLED=$(adb -s "${DEVICE_ID}" shell pm list packages -d | tr -d '\r' | sed 's/^package://')

NEWLY_DISABLED=0
ALREADY_DISABLED=0
NOT_FOUND=0
FAILED=0

echo "[*] Processing ${#PACKAGES[@]} target packages..."
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
