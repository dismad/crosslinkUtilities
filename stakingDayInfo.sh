#!/usr/bin/env bash
# Reports whether the current height is inside a Staking Day window.
# Season 1 rules: new window every 150 blocks, open for 70 blocks.

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"

HEIGHT=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"getblockcount","params":[],"id":1}' \
  "$RPC" | jq -r '.result')

if [[ -z "$HEIGHT" || "$HEIGHT" == "null" ]]; then
  echo "Failed to get block height" >&2
  exit 1
fi

CYCLE=150
WINDOW=70
OFFSET=$(( HEIGHT % CYCLE ))

echo
echo "Current height: $HEIGHT"
echo "Offset in cycle: $OFFSET / $CYCLE"

if (( OFFSET < WINDOW )); then
  REMAINING=$(( WINDOW - OFFSET ))
  echo "Status: IN Staking Day"
  echo "Blocks remaining in window: $REMAINING"
else
  UNTIL_NEXT=$(( CYCLE - OFFSET ))
  echo "Status: OUTSIDE Staking Day"
  echo "Blocks until next Staking Day: $UNTIL_NEXT"
fi
echo
