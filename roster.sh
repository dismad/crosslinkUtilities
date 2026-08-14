#!/usr/bin/env bash
# Show current finalizer roster (stake in ZEC by default)

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"
USE_ZATS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -z|--zats) USE_ZATS=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-z|--zats]"
      echo "  -z, --zats   show stake in zatoshis instead of ZEC"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

METHOD="get_tfl_roster_zec"
if $USE_ZATS; then
  METHOD="get_tfl_roster_zats"
fi

echo
echo "=== Finalizer Roster ($METHOD) ==="
echo

RESULT=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"$METHOD\",\"params\":[],\"id\":1}" \
  "$RPC")

if [[ -z "$RESULT" ]]; then
  echo "No response from $RPC" >&2
  exit 1
fi

# Flexible pretty-print – works with common field names
echo "$RESULT" | jq -r '
  if .result == null then
    "  (null / empty roster)"
  elif (.result | type) == "array" then
    if (.result | length) == 0 then
      "  (empty)"
    else
      .result[] |
      (
        (.finalizer // .pubkey // .pk // .id // "unknown") as $id |
        (.stake_zec // .zec // .stake // .amount // .zats // 0) as $stake |
        "  \($id)  →  \($stake)"
      )
    end
  else
    .
  end
'
echo
