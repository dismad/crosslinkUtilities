#!/usr/bin/env bash
# crosslink-status.sh – short summary by default, full TFL only with -f/--full
RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"
SHOW_FULL_TFL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--full) SHOW_FULL_TFL=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-f|--full]"
      echo "  -f, --full   also dump full get_tfl_recency_status JSON"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

echo
echo "=== Crosslink Status ==="

# Height + Staking Day
HEIGHT=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"getblockcount","params":[],"id":1}' \
  "$RPC" | jq -r '.result // empty')

if [[ -z "$HEIGHT" || ! "$HEIGHT" =~ ^[0-9]+$ ]]; then
  echo "Failed to get block height" >&2
  exit 1
fi

OFFSET=$(( HEIGHT % 150 ))
if (( OFFSET < 70 )); then
  DAY_STATUS="IN Staking Day ($((70 - OFFSET)) blocks left)"
else
  DAY_STATUS="OUTSIDE Staking Day ($((150 - OFFSET)) blocks until next)"
fi

echo "Height:          $HEIGHT"
echo "Staking Day:     $DAY_STATUS"

# Positions + rewards
POS=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"wallet_staking_positions","params":[],"id":1}' \
  "$RPC")

ACTIVE_COUNT=$(echo "$POS" | jq '[.result.active[][]] | length')
WITHDRAWABLE_COUNT=$(echo "$POS" | jq '.result.withdrawable | length')
TOTAL_REWARDS=$(echo "$POS" | jq '([.result.active[][] | (.latest_val - .initial_val)] | add) / 1e8')

echo "Active bonds:    $ACTIVE_COUNT"
echo "Withdrawable:    $WITHDRAWABLE_COUNT"
echo "Total rewards:   ${TOTAL_REWARDS} ZEC"
echo

# TFL section
if $SHOW_FULL_TFL; then
  echo "=== Full TFL Recency Status ==="
  curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"get_tfl_recency_status","params":[],"id":1}' \
    "$RPC" | jq .
  echo
else
  echo "TFL status:      (run with -f / --full to see full JSON)"
  echo
fi
