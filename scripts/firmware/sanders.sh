#!/usr/bin/env bash
# Download Sanders-specific firmware at build time; do not autoload Wi-Fi drivers.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ACTION="${1:-check}"
MODE="${SANDERS_FIRMWARE_MODE:-wcnss}"
URL="${SANDERS_FIRMWARE_URL:-https://gitlab.com/vanadium-oss/motorola-msm8953/mainline/sanders-firmware.git}"
REF="${SANDERS_FIRMWARE_REF:-}"
SOURCE="$ROOT/.work/firmware/sanders-source"

case "$MODE" in
  wcnss|off) ;;
  *) echo 'ERROR: SANDERS_FIRMWARE_MODE must be wcnss or off.' >&2; exit 2 ;;
esac

fetch_firmware() {
  command -v git >/dev/null || { echo 'ERROR: git is required.' >&2; return 1; }
  if [ -d "$SOURCE/.git" ]; then
    if [ "$(git -C "$SOURCE" remote get-url origin)" != "$URL" ]; then
      echo 'ERROR: cached Sanders firmware is from a different repository.' >&2
      return 1
    fi
    if [[ "$REF" =~ ^[0-9a-f]{40}$ ]] && [ "$(git -C "$SOURCE" rev-parse HEAD)" != "$REF" ]; then
      rm -rf "$SOURCE"
    fi
  fi
  if [ ! -d "$SOURCE/.git" ]; then
    mkdir -p "$(dirname "$SOURCE")"
    rm -rf "$SOURCE"
    GIT_TERMINAL_PROMPT=0 git clone -q --depth 1 "$URL" "$SOURCE" || {
      echo "ERROR: cannot clone Sanders firmware from $URL" >&2
      return 1
    }
    if [ -n "$REF" ]; then
      GIT_TERMINAL_PROMPT=0 git -C "$SOURCE" fetch -q --depth 1 origin "$REF" || return 1
      git -C "$SOURCE" checkout -q --detach FETCH_HEAD
    fi
  fi
  if [[ "$REF" =~ ^[0-9a-f]{40}$ ]] && [ "$(git -C "$SOURCE" rev-parse HEAD)" != "$REF" ]; then
    echo 'ERROR: Sanders firmware commit does not match SANDERS_FIRMWARE_REF.' >&2
    return 1
  fi
}

verify_firmware() {
  local src="$SOURCE"
  for f in wlan/WCNSS_qcom_wlan_nv.bin modem/image/wcnss.mdt modem/image/wcnss.b00 modem/image/wcnss.b06; do
    [ -s "$src/$f" ] || { echo "ERROR: missing Sanders firmware $f" >&2; return 1; }
  done
  if [ -s "$src/SHA256SUMS" ]; then
    (cd "$src" && sha256sum --check --status SHA256SUMS) || {
      echo 'ERROR: Sanders firmware SHA256SUMS check failed.' >&2
      return 1
    }
  fi
  echo "Sanders firmware revision: $(git -C "$src" rev-parse HEAD)"
}

if [ "$MODE" = off ]; then
  echo 'Sanders firmware disabled (SANDERS_FIRMWARE_MODE=off).'
  exit 0
fi
case "$ACTION" in
  check|install) ;;
  *) echo 'Usage: sanders.sh check | install TARGET_ROOTFS' >&2; exit 2 ;;
esac
fetch_firmware
verify_firmware
[ "$ACTION" != check ] || exit 0
[ "$#" -eq 2 ] && [ -n "${2:-}" ] && [ "$2" != / ] || {
  echo 'Usage: sanders.sh install TARGET_ROOTFS' >&2; exit 2
}
DEST="$2/lib/firmware"
sudo mkdir -p "$DEST/wlan/prima" "$DEST/qcom/msm8953/motorola/sanders"
for f in "$SOURCE"/modem/image/wcnss.mdt "$SOURCE"/modem/image/wcnss.b[0-9][0-9]; do
  [ -s "$f" ] || { echo "ERROR: WCNSS segment missing: $f" >&2; exit 1; }
  sudo install -m 0644 "$f" "$DEST/$(basename "$f")"
done
NV="$SOURCE/wlan/WCNSS_qcom_wlan_nv.bin"
sudo install -m 0644 "$NV" "$DEST/wlan/prima/WCNSS_qcom_wlan_nv.bin"
sudo install -m 0644 "$NV" "$DEST/qcom/msm8953/motorola/sanders/WCNSS_qcom_wlan_nv.bin"
echo 'Sanders WCNSS firmware staged without enabling drivers or services.'
