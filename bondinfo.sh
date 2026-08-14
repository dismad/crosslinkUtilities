#!/usr/bin/env bash
# Lookup a specific bond by bond_key / pk
# Note: pk from wallet_staking_positions is byte-reversed PubKeyID JSON.
# getbondinfo expects the native (non-reversed) 32-byte key.

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <bond_key>"
  echo
  echo "  bond_key = 64-char hex pk from listStakingInfo.sh"
  echo "  (script reverses byte order for getbondinfo)"
  exit 0
fi

BOND_KEY_JSON="$1"

if [[ ! "$BOND_KEY_JSON" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Error: bond_key must be exactly 64 hex characters (32 bytes)" >&2
  exit 1
fi

# Reverse byte order: JSON PubKeyID → native BondKey
BOND_KEY_NATIVE=$(echo "$BOND_KEY_JSON" | fold -w2 | tac | tr -d '\n')

echo
echo "=== Bond Info ==="
echo "pk (from wallet JSON):  $BOND_KEY_JSON"
echo "key (for getbondinfo):  $BOND_KEY_NATIVE"
echo

BODY=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "$(printf '{"jsonrpc":"2.0","method":"getbondinfo","params":["%s"],"id":1}' "$BOND_KEY_NATIVE")" \
  "$RPC")

if [[ -z "$BODY" ]]; then
  echo "Empty response. Is the node running?"
  exit 1
fi

echo "$BODY" | jq -r '
  if .error then
    "RPC error: " + (.error.message // (.error|tostring))
  elif .result == null then
    "Bond not found in chain state (result is null)."
  else
    "amount:              " + (.result.amount|tostring) + " zats",
    "status:              " + (.result.status|tostring) + " (0=Active, 1=Unbonding, 2=Withdrawn)",
    "last_action_height:  " + (.result.last_action_height|tostring)
  end
'
echo
