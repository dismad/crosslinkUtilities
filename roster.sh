#!/usr/bin/env bash
Show current finalizer roster
RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"
USE_ZATS=false
RAW=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -z|--zats) USE_ZATS=true; shift ;;
    -r|--raw)  RAW=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-z|--zats] [-r|--raw]"
      echo "  -z, --zats   use get_tfl_roster_zats"
      echo "  -r, --raw    dump raw JSON"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if $USE_ZATS; then
  METHOD="get_tfl_roster_zats"
else
  METHOD="get_tfl_roster_zec"
fi

PAYLOAD=$(printf '{"jsonrpc":"2.0","method":"%s","params":[],"id":1}' "$METHOD")

echo
echo "=== Finalizer Roster ($METHOD) ==="
echo

BODY=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$RPC")

if [[ -z "$BODY" ]]; then
  echo "Empty response. Is the node running?"
  exit 1
fi

if $RAW; then
  echo "$BODY" | jq .
  echo
  exit 0
fi

echo "$BODY" | jq -r '
  if .error then
    "RPC error: " + (.error.message // (.error|tostring))
  elif .result == null then
    "result is null"
  elif (.result | type) != "array" then
    "Unexpected result type: " + (.result|type)
  elif (.result | length) == 0 then
    "(empty roster)"
  else
    .result
    | sort_by(.[1])
    | reverse
    | .[]
    | "  " + (.[0]|tostring) + "  →  " + (.[1]|tostring)
  end
'
echo
