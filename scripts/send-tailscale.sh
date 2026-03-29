#!/bin/bash
# kirim.sh — Send file(s)/folder(s) to a Tailscale peer
# Usage: kirim <file|folder> [file2 folder2 ...]

# NOTE: intentionally no 'set -e' — we want the loop to continue on send failure
set -uo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
die() {
  echo -e "${RED}✗ $*${RESET}" >&2
  exit 1
}
ok() { echo -e "${GREEN}✓ $*${RESET}"; }
info() { echo -e "${CYAN}→ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $*${RESET}"; }

# ── Pre-flight ────────────────────────────────────────────────────────────────
command -v tailscale >/dev/null 2>&1 || die "tailscale is not installed or not in PATH."

[[ $# -eq 0 ]] && {
  echo -e "${BOLD}Usage:${RESET} kirim <file|folder> [file2 folder2 ...]"
  echo -e "       kirim --help"
  exit 1
}

[[ "$1" == "--help" || "$1" == "-h" ]] && {
  echo -e "${BOLD}kirim${RESET} — Send files/folders to a Tailscale peer"
  echo ""
  echo -e "${BOLD}Usage:${RESET}"
  echo "  kirim <file|folder> [file2 folder2 ...]"
  echo ""
  echo -e "${BOLD}Examples:${RESET}"
  echo "  kirim report.pdf"
  echo "  kirim photo.jpg notes.txt archive/"
  exit 0
}

# ── Get online Tailscale peers ────────────────────────────────────────────────
info "Fetching online Tailscale peers..."

PEER_NAMES=()
PEER_IPS=()

while IFS=$'\t' read -r name ip; do
  PEER_NAMES+=("$name")
  PEER_IPS+=("$ip")
done < <(
  tailscale status --json 2>/dev/null |
    python3 -c "
import sys, json
data = json.load(sys.stdin)
peers = data.get('Peer', {})
for p in peers.values():
    if p.get('Online', False):
        name = p.get('HostName', 'unknown')
        ip   = p.get('TailscaleIPs', [''])[0]
        if ip:
            print(f'{name}\t{ip}')
" 2>/dev/null
)

[[ ${#PEER_NAMES[@]} -eq 0 ]] && die "No online Tailscale peers found. Make sure Tailscale is running."

# ── Peer selection ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Online peers:${RESET}"
for i in "${!PEER_NAMES[@]}"; do
  echo -e "  ${CYAN}[$((i + 1))]${RESET} ${PEER_NAMES[$i]}  (${PEER_IPS[$i]})"
done
echo ""

PEER_COUNT=${#PEER_NAMES[@]}
while true; do
  read -rp "$(echo -e "${BOLD}Select peer [1-${PEER_COUNT}]:${RESET} ")" CHOICE
  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$PEER_COUNT" ]; then
    break
  fi
  warn "Invalid choice. Enter a number between 1 and ${PEER_COUNT}."
done

TARGET_IP="${PEER_IPS[$((CHOICE - 1))]}"
TARGET_NAME="${PEER_NAMES[$((CHOICE - 1))]}"

echo ""
info "Target: ${BOLD}${TARGET_NAME}${RESET} ${CYAN}(${TARGET_IP})${RESET}"
echo ""

# ── Validate files & auto-zip folders ────────────────────────────────────────
ZIP_TMPDIR=$(mktemp -d)
trap 'rm -rf "$ZIP_TMPDIR"' EXIT

FILES=()
for f in "$@"; do
  if [[ -f "$f" ]]; then
    FILES+=("$f")
  elif [[ -d "$f" ]]; then
    ZIPNAME="${ZIP_TMPDIR}/$(basename "$f").zip"
    info "Folder detected — compressing '$(basename "$f")' ..."
    if zip -r "$ZIPNAME" "$f" -x "*.DS_Store" >/dev/null 2>&1; then
      ok "Compressed: $(basename "$ZIPNAME") ($(du -sh "$ZIPNAME" | cut -f1))"
      FILES+=("$ZIPNAME")
    else
      warn "Failed to compress '$f', skipping."
    fi
  else
    warn "Skipping '$f' — not found."
  fi
done

[[ ${#FILES[@]} -eq 0 ]] && die "No valid files to send."

# ── Send ──────────────────────────────────────────────────────────────────────
echo -e "${BOLD}Sending ${#FILES[@]} file(s) to ${TARGET_NAME}...${RESET}"
echo ""

SENT=0
FAILED=0

for f in "${FILES[@]}"; do
  BASENAME=$(basename "$f")
  SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
  echo -e "  ${CYAN}↑${RESET} ${BASENAME} ${YELLOW}(${SIZE})${RESET}"

  if tailscale file cp "$f" "${TARGET_IP}:" 2>&1; then
    ok "  Sent: ${BASENAME}"
    SENT=$((SENT + 1))
  else
    warn "  Failed: ${BASENAME}"
    FAILED=$((FAILED + 1))
  fi
  echo ""
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}─────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}Sent:   ${SENT}${RESET}"
[[ $FAILED -gt 0 ]] && echo -e "  ${RED}Failed: ${FAILED}${RESET}"
echo -e "  Target: ${TARGET_NAME} (${TARGET_IP})"
echo -e "${BOLD}─────────────────────────────────────────${RESET}"

[[ $FAILED -gt 0 ]] && exit 1
exit 0
