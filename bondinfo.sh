#!/usr/bin/env bash
# Lookup a specific bond by bond_key / pk

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <bond_key>"
  echo "  bond_key is the pk field from wallet_staking_positions / listStakingInfo.sh"
  exit 0
fi

BOND_KEY="$1"

echo
echo "=== Bond Info: $BOND_KEY ==="
echo

curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"getbondinfo\",\"params\":[\"$BOND_KEY\"],\"id\":1}" \
  "$RPC" | jq .
echo
