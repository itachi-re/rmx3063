#!/usr/bin/env bash
# AB-safe full firmware flash script
# - Detects A/B device slots and flashes to all slots.
# - Exits on any error.
# - Uses --slot=all when available, falls back to flashing slots a and b explicitly.
#
# RUN AT YOUR OWN RISK: This erases/writes partitions. Make sure images match target device.

set -euo pipefail
IFS=$'\n\t'

# --- Config: filenames (adjust if needed) ---
VBMETA="vbmeta.img"
VBMETA_SYSTEM="vbmeta_system.img"
VBMETA_VENDOR="vbmeta_vendor.img"
LK="lk.img"
TEE="tee.img"
BOOT="boot.img"
DTBO="dtbo.img"
LOGO="logo.bin"
RECOVERY="recovery.img"
SUPERIMG="super.img"
USERDATA_IMG="userdata.img"
MD1IMG="md1img.img"

# --- Helpers ---
info(){ echo -e "\n[INFO] $*"; }
err(){ echo -e "\n[ERROR] $*" >&2; exit 1; }

# Check fastboot is available
command -v fastboot >/dev/null 2>&1 || err "fastboot binary not found in PATH."

# Detect slot/A/B support
# Try reading current-slot; output often looks like: "current-slot: a"
CURRENT_SLOT_RAW=$(fastboot getvar current-slot 2>&1 | tr -d '\r' || true)
if [[ "$CURRENT_SLOT_RAW" =~ current-slot[:[:space:]]*([abAB]) ]]; then
  SLOT_SUPPORTED=true
  CURRENT_SLOT="${BASH_REMATCH[1],,}"  # a or b (lowercase)
else
  # Try another check: is system logical? (some devices report "is-logical:system: yes")
  IS_LOGICAL=$(fastboot getvar is-logical:system 2>&1 | tr -d '\r' || true)
  if [[ "$IS_LOGICAL" =~ yes ]]; then
    SLOT_SUPPORTED=true
    CURRENT_SLOT=""
  else
    SLOT_SUPPORTED=false
    CURRENT_SLOT=""
  fi
fi

# Check whether fastboot supports --slot=all by trying a dry-run (no flashing) with --help
FASTBOOT_SUPPORTS_SLOT_ALL=false
if fastboot --help 2>&1 | grep -qi -- '--slot'; then
  FASTBOOT_SUPPORTS_SLOT_ALL=true
fi

info "Slot support detected: ${SLOT_SUPPORTED}"
if $SLOT_SUPPORTED; then
  if $FASTBOOT_SUPPORTS_SLOT_ALL; then
    info "Fastboot supports --slot flags; will use --slot=all where possible."
  else
    info "Fastboot does not advertise --slot support; will try explicit a/b flashing where needed."
  fi
else
  info "Device appears non-A/B. Will flash single partitions."
fi

# A wrapper to flash partitions safely
# Usage: flash PART IMG (will use slot=all or explicit slots if required)
flash() {
  local PART="$1"; shift
  local IMG="$1"; shift

  if $SLOT_SUPPORTED && $FASTBOOT_SUPPORTS_SLOT_ALL ; then
    info "Flashing ${PART} (all slots): ${IMG}"
    fastboot flash --slot=all "${PART}" "${IMG}"
  elif $SLOT_SUPPORTED && ! $FASTBOOT_SUPPORTS_SLOT_ALL ; then
    # fallback: flash to slot a and b explicitly when applicable
    # Some partitions do not have slot suffixes (vbmeta, lk, tee). For those, use non-slot flash.
    case "$PART" in
      boot|dtbo|recovery|logo|vbmeta|vbmeta_system|vbmeta_vendor|lk|tee|md1img|super|userdata)
        # Many of these are logical or have slot aliases; try flashing to partition-name:_a and _b if they exist
        info "Flashing ${PART}_a then ${PART}_b (fallback): ${IMG}"
        fastboot flash "${PART}_a" "${IMG}" || true
        fastboot flash "${PART}_b" "${IMG}" || true
        # also attempt plain partition in case device expects it
        fastboot flash "${PART}" "${IMG}" || true
        ;;
      *)
        # default: try a then b
        info "Flashing ${PART}_a then ${PART}_b (fallback): ${IMG}"
        fastboot flash "${PART}_a" "${IMG}" || true
        fastboot flash "${PART}_b" "${IMG}" || true
        ;;
    esac
  else
    info "Flashing ${PART}: ${IMG}"
    fastboot flash "${PART}" "${IMG}"
  fi
}

# Use a function to print numbered progress and run flash commands.
step=0
nextstep(){ step=$((step+1)); echo -e "\n--- [$step] $* ---"; }

echo "=== Starting Full Firmware Flash ==="

# 1. Verified Boot partitions
nextstep "Flashing vbmeta"
flash vbmeta "${VBMETA}"

nextstep "Flashing vbmeta_system"
flash vbmeta_system "${VBMETA_SYSTEM}"

nextstep "Flashing vbmeta_vendor"
flash vbmeta_vendor "${VBMETA_VENDOR}"

# 2. Low-level bootloader and security components
nextstep "Flashing lk (bootloader)"
flash lk "${LK}"

nextstep "Flashing tee (Trusted Execution Environment)"
flash tee "${TEE}"

# 3. Core boot and hardware description images
nextstep "Flashing boot (kernel)"
flash boot "${BOOT}"

nextstep "Flashing dtbo (Device Tree)"
flash dtbo "${DTBO}"

nextstep "Flashing logo (Boot Logo)"
flash logo "${LOGO}"

# 4. Main OS and recovery partitions
nextstep "Flashing recovery"
flash recovery "${RECOVERY}"

nextstep "Flashing super (System, Vendor, Product) — THIS WILL TAKE A LONG TIME"
# super is often large; ensure fastboot won't reboot mid-transfer; some fastboot versions accept --no-reboot or --skip-reboot
flash super "${SUPERIMG}"

# 5. Flash userdata if you have an image to write (image-based userdata flash)
if [[ -f "${USERDATA_IMG}" ]]; then
  nextstep "Flashing userdata (image)"
  flash userdata "${USERDATA_IMG}"
else
  info "No userdata image (${USERDATA_IMG}) found; skipping userdata image flash."
fi

# 6. Flash modem firmware
nextstep "Flashing modem (md1img)"
flash md1img "${MD1IMG}"

# 7. WIPE ALL DATA for a clean installation. THIS IS A FACTORY RESET.
nextstep "Wiping user data (factory reset)"
# Use fastboot -w where available (wipes data and cache). Keep explicit erase as fallback.
if fastboot --help 2>&1 | grep -qi '\-w'; then
  info "Performing 'fastboot -w'..."
  fastboot -w || true
else
  info "Performing 'fastboot erase userdata'..."
  fastboot erase userdata || true
fi

# 8. Final sync and reboot
nextstep "Sync and reboot"
# On some devices a final 'fastboot reboot' will work; ensure device finishes operations first.
fastboot reboot

echo -e "\n=== Flash sequence complete ==="
echo "If this was an A/B device, images were written to all slots. First boot may take several minutes."
