#!/usr/bin/env bash
# Show current finalized tip and optionally check a block or tx hash

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"
CHECK_HASH=""
CHECK_TYPE="block"   # block | tx

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--block)
      CHECK_HASH="$2"
      CHECK_TYPE="block"
      shift 2
      ;;
    -t|--tx)
      CHECK_HASH="$2"
      CHECK_TYPE="tx"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-b|--block <hash>] [-t|--tx <hash>]"
      echo "  (no args)     show current finalized tip"
      echo "  -b, --block   check finality of a block hash"
      echo "  -t, --tx      check finality of a transaction hash"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

echo
echo "=== Finality ==="

# Always show current finalized tip
TIP=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"get_tfl_final_block_height_and_hash","params":[],"id":1}' \
  "$RPC")

echo
echo "Finalized tip:"
echo "$TIP" | jq -r '
  if .result == null then
    "  (null)"
  else
    "  height: \(.result.height // .result.block_height // "unknown")",
    "  hash:   \(.result.hash // .result.block_hash // .result // "unknown")"
  end
'

# Optional single hash check
if [[ -n "$CHECK_HASH" ]]; then
  if [[ "$CHECK_TYPE" == "block" ]]; then
    METHOD="get_tfl_block_finality_from_hash"
  else
    METHOD="get_tfl_tx_finality_from_hash"
  fi

  echo
  echo "Checking $CHECK_TYPE $CHECK_HASH ..."
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"$METHOD\",\"params\":[\"$CHECK_HASH\"],\"id\":1}" \
    "$RPC" | jq .
fi

echo
