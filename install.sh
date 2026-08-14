#!/usr/bin/env bash
# Install crosslinkUtilities scripts + ensure curl & jq are present
# Usage:
#   curl -sL https://raw.githubusercontent.com/dismad/crosslinkUtilities/main/install.sh | bash
#   ./install.sh [target_dir]

set -euo pipefail

REPO="https://raw.githubusercontent.com/dismad/crosslinkUtilities/main"
SCRIPTS=(
  crosslinkStatus.sh
  listRewards.sh
  listStakingInfo.sh
  stakingDayInfo.sh
  roster.sh
  finality.sh
  bondinfo.sh
)

TARGET_DIR="${1:-$HOME/crosslinkUtilities}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_deps() {
  local missing=()
  need_cmd curl || missing+=("curl")
  need_cmd jq   || missing+=("jq")

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "Dependencies OK (curl, jq)"
    return 0
  fi

  echo "Missing dependencies: ${missing[*]}"
  echo "Attempting to install..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if need_cmd apt-get; then
      sudo apt-get update -qq
      sudo apt-get install -y -qq curl jq
    elif need_cmd dnf; then
      sudo dnf install -y curl jq
    elif need_cmd yum; then
      sudo yum install -y curl jq
    elif need_cmd pacman; then
      sudo pacman -Sy --noconfirm curl jq
    elif need_cmd zypper; then
      sudo zypper install -y curl jq
    else
      echo "Unsupported Linux package manager. Please install curl and jq manually." >&2
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if need_cmd brew; then
      brew install curl jq
    else
      echo "Homebrew not found. Install it from https://brew.sh or install curl/jq manually." >&2
      exit 1
    fi
  else
    echo "Unsupported OS. Please install curl and jq manually." >&2
    exit 1
  fi

  # Final check
  if ! need_cmd curl || ! need_cmd jq; then
    echo "Failed to install curl and/or jq." >&2
    exit 1
  fi

  echo "Dependencies installed successfully."
}

echo
echo "=== crosslinkUtilities installer ==="
echo

install_deps

echo
echo "Installing scripts → $TARGET_DIR"
mkdir -p "$TARGET_DIR"

for script in "${SCRIPTS[@]}"; do
  echo "  downloading $script"
  curl -fsSL "$REPO/$script" -o "$TARGET_DIR/$script"
  chmod +x "$TARGET_DIR/$script"
done

echo
echo "Done."
echo
echo "Scripts installed to: $TARGET_DIR"
echo
echo "Add to your PATH (optional):"
echo "  export PATH=\"\$PATH:$TARGET_DIR\""
echo
echo "Example:"
echo "  $TARGET_DIR/crosslinkStatus.sh"
echo
