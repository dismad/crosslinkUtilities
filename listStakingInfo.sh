#!/usr/bin/env bash
# Pretty-prints all staking positions with rewards and bond keys (pk)
RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"

JSON=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"wallet_staking_positions","params":[],"id":1}' \
  "$RPC")

echo
echo "=== Active positions ==="

echo "$JSON" | jq -r '
  .result.active | to_entries[] | 
  "Finalizer: " + .key,
  (.value[] | 
    "  bond_key (pk): " + .pk,
    "  create_height: " + (.create_height|tostring),
    "  initial: " + ((.initial_val / 1e8)|tostring) + " ZEC",
    "  latest:  " + ((.latest_val / 1e8)|tostring) + " ZEC",
    "  rewards: " + (((.latest_val - .initial_val) / 1e8)|tostring) + " ZEC",
    ""
  )
'

echo "=== Withdrawable positions ==="

echo "$JSON" | jq -r '
  if (.result.withdrawable | length) == 0 then
    "  (none)"
  else
    .result.withdrawable[] |
    "  bond_key (pk): " + (.pk // .bond_key // "unknown"),
    "  value: " + (((.latest_val // .value // 0) / 1e8)|tostring) + " ZEC",
    ""
  end
'

echo
