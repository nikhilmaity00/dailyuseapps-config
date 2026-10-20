#!/usr/bin/env bash
# ==============================================================================
# OnePlus Nord 5 (OxygenOS 16.0.1 / ColorOS Base) Safe Restore Suite
# Target Device: OnePlus Nord 5 (CPH2707 / Android 16 / OxygenOS 16.0.1)
# Mode: Safe Re-enabling (pm enable) - 100% Non-destructive & Immediate
# Includes: Pre/Post RAM telemetry, logging, and automatic device detection
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
echo " OnePlus Nord 5 (OxygenOS 16.0.1) Safe Restore Suite"
echo " Target Device: ${DEVICE_MODEL} (Serial: ${DEVICE_ID})"
echo " Session Log:   ${SESSION_LOG}"
echo " History Log:   ${HISTORY_LOG}"
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
  # Group 1: HeyTap Ecosystem & Advertising Services
  "com.heytap.browser"
  "com.heytap.cloud"
  "com.heytap.market"
  "com.heytap.market.overlay"
  "com.heytap.mcs"
  "com.heytap.pictorial"
  "com.heytap.htms"
  "com.nearme.instant.platform"

  # Group 2: Oplus Telemetry & Loggers
  "com.oplus.statistics.rom"
  "com.oplus.crashbox"
  "com.oplus.logkit"
  "com.oplus.lfeh"
  "com.oplus.onetrace"
  "com.oplus.dmp"
  "com.oplus.qualityprotect"
  "com.oplus.sau"
  "com.oplus.sauhelper"
  "com.oplus.cota"
  "com.oplus.bttestmode"
  "com.oplus.nfcengineertest"
  "com.oplus.wifibackuprestore"
  "com.coloros.activation"

  # Group 3: Commercial Bloatware, Store Apps & Preloads
  "com.oneplus.mall"
  "com.oneplus.membership"
  "com.oplus.omoji"
  "com.oplus.pay"
  "com.oplus.securepay"
  "com.oplus.securitykeyboard"
  "com.oplus.upgradeguide"
  "com.redteamobile.roaming"
  "com.wapi.wapicertmanage"
  "com.facebook.appmanager"
  "com.facebook.services"
  "com.facebook.system"
  "android.autoinstalls.config.oneplus"

  # Group 4: Auxiliary ColorOS Gimmicks
  "com.coloros.childrenspace"
  "com.coloros.video"
  "com.coloros.ocrscanner"
  "com.coloros.operationManual"
  "com.oplus.riderMode"

  # Group 5: Google Telemetry & Fluff
  "com.google.android.feedback"
  "com.google.android.partnersetup"
  "com.google.android.printservice.recommendation"
  "com.google.ar.core"
  "com.google.ar.lens"
  "com.google.android.onetimeinitializer"
  "com.android.traceur"
  "com.android.egg"
  "com.android.bluetoothmidiservice"
  "com.android.providers.partnerbookmarks"
  "com.android.email.partnerprovider"
)

# Fetch status
ALL_INSTALLED=$(adb -s "${DEVICE_ID}" shell pm list packages -u | tr -d '\r' | sed 's/^package://')
CURRENTLY_DISABLED=$(adb -s "${DEVICE_ID}" shell pm list packages -d | tr -d '\r' | sed 's/^package://')

RESTORED=0
ALREADY_ENABLED=0
NOT_FOUND=0
FAILED=0

echo "[*] Restoring ${#PACKAGES[@]} target packages..."
echo "----------------------------------------------------------"

for pkg in "${PACKAGES[@]}"; do
  # Check if present in package database
  if ! echo "${ALL_INSTALLED}" | grep -q "^${pkg}$"; then
    log " [SKIP - NOT FOUND]      ${pkg}"
    ((NOT_FOUND++))
    continue
  fi

  # Check if already enabled
  if ! echo "${CURRENTLY_DISABLED}" | grep -q "^${pkg}$"; then
    log " [ALREADY ENABLED]       ${pkg}"
    ((ALREADY_ENABLED++))
    continue
  fi

  OUTPUT=$(adb -s "${DEVICE_ID}" shell pm enable "${pkg}" 2>&1 | tr -d '\r')
  if [[ "$OUTPUT" == *"enabled"* ]] || [[ "$OUTPUT" == *"new state: default"* ]]; then
    log " [RESTORED / ENABLED]    ${pkg}"
    ((RESTORED++))
  else
    log " [ERROR - FAILED]        ${pkg} (Output: ${OUTPUT})"
    ((FAILED++))
  fi
done

echo "----------------------------------------------------------"
log "[+] Restore Summary for ${DEVICE_MODEL} (${DEVICE_ID}):"
log "    Successfully restored:   ${RESTORED}"
log "    Already enabled:         ${ALREADY_ENABLED}"
log "    Not found in database:   ${NOT_FOUND}"
log "    Failed / Errors:         ${FAILED}"
log "    Total target packages:   ${#PACKAGES[@]}"
echo ""

# Measure RAM after restore
echo "[*] Querying post-restore memory stats..."
sleep 1
RAM_POST=$(get_ram_info "${DEVICE_ID}")
read -r _ POST_AVAIL_KB POST_FREE_KB POST_USED_KB <<< "${RAM_POST}"

POST_AVAIL_STR=$(fmt_mb "${POST_AVAIL_KB}")
POST_USED_STR=$(fmt_mb "${POST_USED_KB}")
POST_AVAIL_PCT=$(fmt_pct "${POST_AVAIL_KB}" "${TOTAL_KB}")
POST_USED_PCT=$(fmt_pct "${POST_USED_KB}" "${TOTAL_KB}")

log "=========================================================="
log " [RAM COMPARISON]"
log "   Total RAM:              ${TOTAL_RAM_STR}"
log "   Available (Before):     ${PRE_AVAIL_STR} (${PRE_AVAIL_PCT})"
log "   Available (After):      ${POST_AVAIL_STR} (${POST_AVAIL_PCT})"
log "   Used RAM (Before):      ${PRE_USED_STR} (${PRE_USED_PCT})"
log "   Used RAM (After):       ${POST_USED_STR} (${POST_USED_PCT})"
log "=========================================================="
echo "Logs saved to: ${SESSION_LOG}"
echo "=========================================================="
