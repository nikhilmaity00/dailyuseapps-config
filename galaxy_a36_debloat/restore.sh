#!/usr/bin/env bash
# ==============================================================================
# Universal Samsung One UI Restore / Re-enable Suite
# Target: Restores all packages managed by debloat.sh
# Includes: Pre/Post RAM telemetry and session audit logging
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SCRIPT_DIR}/logs"
mkdir -p "${LOGS_DIR}"

if ! command -v adb &> /dev/null; then
  echo "[-] Error: 'adb' command not found in PATH."
  exit 1
fi

DEVICE_ID="${1:-$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')}"

if [[ -z "${DEVICE_ID}" ]]; then
  echo "[-] Error: No Android device detected."
  exit 1
fi

if ! adb -s "${DEVICE_ID}" get-state &> /dev/null; then
  echo "[-] Error: Device ${DEVICE_ID} not detected or unauthorized."
  exit 1
fi

DEVICE_MODEL=$(adb -s "${DEVICE_ID}" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HUMAN_TIME=$(date +"%Y-%m-%d %H:%M:%S")
SESSION_LOG="${LOGS_DIR}/restore_${DEVICE_MODEL}_${TIMESTAMP}.log"
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
echo " Samsung One UI Safe Restore Suite"
echo " Target Device: ${DEVICE_MODEL} (Serial: ${DEVICE_ID})"
echo " Session Log:   ${SESSION_LOG}"
echo "=========================================================="
echo ""

echo "=== Restore Session Started at ${HUMAN_TIME} for ${DEVICE_MODEL} (${DEVICE_ID}) ===" >> "${SESSION_LOG}"
echo "=== Restore Session Started at ${HUMAN_TIME} for ${DEVICE_MODEL} (${DEVICE_ID}) ===" >> "${HISTORY_LOG}"

# Measure RAM before restore
RAM_PRE=$(get_ram_info "${DEVICE_ID}")
read -r TOTAL_KB PRE_AVAIL_KB PRE_FREE_KB PRE_USED_KB <<< "${RAM_PRE}"
TOTAL_RAM_STR=$(fmt_mb "${TOTAL_KB}")
PRE_AVAIL_STR=$(fmt_mb "${PRE_AVAIL_KB}")
PRE_USED_STR=$(fmt_mb "${PRE_USED_KB}")
PRE_AVAIL_PCT=$(fmt_pct "${PRE_AVAIL_KB}" "${TOTAL_KB}")
PRE_USED_PCT=$(fmt_pct "${PRE_USED_KB}" "${TOTAL_KB}")

log "----------------------------------------------------------"
log " [RAM BEFORE RESTORE]"
log "   Total RAM:      ${TOTAL_RAM_STR}"
log "   Available RAM:  ${PRE_AVAIL_STR} (${PRE_AVAIL_PCT})"
log "   Used RAM:       ${PRE_USED_STR} (${PRE_USED_PCT})"
log "----------------------------------------------------------"
echo ""

PACKAGES=(
  # Core Lag & Telemetry
  "com.samsung.android.game.gos"
  "com.samsung.android.game.gamehome"
  "com.samsung.android.app.spage"
  "com.samsung.slsi.telephony.silentlogging"
  "com.samsung.android.rubin.app"
  "com.samsung.attribution"
  "com.samsung.oda.service"
  "com.samsung.mfcontents"
  "com.mygalaxy.service"
  "com.samsung.android.beaconmanager"
  "com.hiya.star"

  # Diagnostics & Telemetry
  "com.sec.android.diagmonagent"
  "com.sec.location.nsflp2"
  "com.sec.spp.push"
  "com.samsung.android.knox.analytics.uploader"
  "com.samsung.aasaservice"
  "com.sec.imslogger"

  # Google Daemons
  "com.google.android.googlequicksearchbox"
  "com.google.android.as"
  "com.google.android.apps.turbo"
  "com.google.ar.core"
  "com.google.android.printservice.recommendation"

  # Samsung Cloud & Multi-Device
  "com.samsung.android.scloud"
  "com.sec.android.easyMover"
  "com.sec.android.easyMover.Agent"
  "com.microsoft.appmanager"
  "com.samsung.android.mdx"
  "com.samsung.android.mdecservice"

  # Password Vault
  "com.samsung.android.samsungpass"
  "com.samsung.android.samsungpassautofill"

  # Gallery Stories
  "com.samsung.storyservice"

  # Bixby Suite
  "com.samsung.android.bixby.wakeup"
  "com.samsung.android.bixbyvision.framework"

  # AR & Camera Extras
  "com.samsung.android.aremojieditor"
  "com.snap.camerakit.plugin.v1"
  "com.samsung.android.app.camera.sticker.facearavatar.preload"
  "com.samsung.android.stickercenter"

  # Marketing & Partner Preloads
  "com.samsung.android.kidsinstaller"
  "com.samsung.android.app.parentalcare"
  "com.facebook.services"
  "com.facebook.appmanager"
  "com.facebook.system"
  "android.autoinstalls.config.samsung"

  # Wearables & Wallet
  "com.samsung.accessory.budsunitemgr"
  "com.samsung.android.spayfw"

  # Factory Diagnostics & Secret Test Tools
  "com.sec.android.app.hwmoduletest"
  "com.sec.android.app.servicemodeapp"
  "com.sec.android.app.wlantest"
  "com.sec.android.app.factorykeystring"
  "com.sec.factory.camera"
  "com.sec.factory.cameralyzer"
  "com.sem.factoryapp"
  "com.sec.epdgtestapp"
  "com.sec.modem.settings"
  "com.sec.android.RilServiceModeApp"
  "com.sec.phone"
  "com.samsung.ipservice"
  "com.sec.android.app.parser"

  # Obsolete Carrier Provisioning & Stubs
  "com.wsomacp"
  "com.sec.vsim.ericssonnsds.webapp"
  "com.sec.bcservice"
  "com.samsung.crane"
  "com.samsung.android.smartcallprovider"

  # Unused Foreign TTS Voice Packs
  "com.samsung.SMT.lang_de_de_f00"
  "com.samsung.SMT.lang_fr_fr_f00"
  "com.samsung.SMT.lang_it_it_f00"
  "com.samsung.SMT.lang_es_es_f00"
  "com.samsung.SMT.lang_es_us_f00"
  "com.samsung.SMT.lang_pt_br_f00"
  "com.samsung.SMT.lang_ru_ru_f00"
  "com.samsung.SMT.lang_th_th_f00"
  "com.samsung.SMT.lang_vi_vn_f00"
  "com.samsung.SMT.lang_id_id_f00"
  "com.samsung.SMT.lang_pl_pl_f00"

  # Android & Google Legacy Fluff
  "com.android.egg"
  "com.android.dreams.phototable"
  "com.android.bluetoothmidiservice"
  "com.android.calllogbackup"
  "com.android.providers.partnerbookmarks"
  "com.android.hotwordenrollment.okgoogle"
  "com.android.hotwordenrollment.xgoogle"
  "com.google.android.onetimeinitializer"
  "com.google.android.partnersetup"
  "com.google.android.feedback"
)

ALL_PACKAGES=$(adb -s "${DEVICE_ID}" shell pm list packages -u | tr -d '\r' | sed 's/^package://')

RESTORED=0
NOT_FOUND=0
FAILED=0

echo "[*] Restoring ${#PACKAGES[@]} packages..."
echo "----------------------------------------------------------"

for pkg in "${PACKAGES[@]}"; do
  if ! echo "${ALL_PACKAGES}" | grep -q "^${pkg}$"; then
    log " [SKIP - NOT INSTALLED]  ${pkg}"
    ((NOT_FOUND++))
    continue
  fi

  OUTPUT=$(adb -s "${DEVICE_ID}" shell pm enable "${pkg}" 2>&1 | tr -d '\r')
  if [[ "$OUTPUT" == *"enabled"* ]] || [[ "$OUTPUT" == *"new state: enabled"* ]]; then
    log " [OK - ENABLED]          ${pkg}"
    ((RESTORED++))
  else
    log " [ERROR - FAILED]        ${pkg} (Output: ${OUTPUT})"
    ((FAILED++))
  fi
done

echo "----------------------------------------------------------"
log "[+] Summary for ${DEVICE_MODEL} (${DEVICE_ID}):"
log "    Successfully enabled:    ${RESTORED}"
log "    Not found on device:     ${NOT_FOUND}"
log "    Failed / Errors:         ${FAILED}"
log "    Total target packages:   ${#PACKAGES[@]}"
echo ""

# Measure RAM after restore
sleep 1
RAM_POST=$(get_ram_info "${DEVICE_ID}")
read -r _ POST_AVAIL_KB POST_FREE_KB POST_USED_KB <<< "${RAM_POST}"
POST_AVAIL_STR=$(fmt_mb "${POST_AVAIL_KB}")
POST_USED_STR=$(fmt_mb "${POST_USED_KB}")
POST_AVAIL_PCT=$(fmt_pct "${POST_AVAIL_KB}" "${TOTAL_KB}")
POST_USED_PCT=$(fmt_pct "${POST_USED_KB}" "${TOTAL_KB}")

log "=========================================================="
log " [RAM AFTER RESTORE]"
log "   Total RAM:              ${TOTAL_RAM_STR}"
log "   Available (Before):     ${PRE_AVAIL_STR} (${PRE_AVAIL_PCT})"
log "   Available (After):      ${POST_AVAIL_STR} (${POST_AVAIL_PCT})"
log "   Used RAM (Before):      ${PRE_USED_STR} (${PRE_USED_PCT})"
log "   Used RAM (After):       ${POST_USED_STR} (${POST_USED_PCT})"
log "=========================================================="
