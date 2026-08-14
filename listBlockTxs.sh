#!/usr/bin/env bash
# listBlockTxs.sh – list transactions in a block by height or hash

RPC="${ZEBRAD_RPC:-http://127.0.0.1:8232}"
VERBOSE=1
RAW=false

usage() {
  echo "Usage: $0 <height|hash> [-v 0|1|2] [-r|--raw]"
  echo
  echo "  height|hash   block height (e.g. 12345) or block hash"
  echo "  -v 0|1|2      getblock verbosity (default: 1)"
  echo "                  0 = raw hex"
  echo "                  1 = JSON with txid list"
  echo "                  2 = JSON with full tx objects"
  echo "  -r, --raw     dump full getblock JSON"
  exit 0
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

TARGET="$1"
shift

while [[ $# -gt 0 ]]; do
  case $1 in
    -v)
      VERBOSE="$2"
      shift 2
      ;;
    -r|--raw)
      RAW=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! "$VERBOSE" =~ ^[012]$ ]]; then
  echo "Error: -v must be 0, 1, or 2" >&2
  exit 1
fi

PAYLOAD=$(printf '{"jsonrpc":"2.0","method":"getblock","params":["%s",%s],"id":1}' "$TARGET" "$VERBOSE")

BODY=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$RPC")

if [[ -z "$BODY" ]]; then
  echo "Empty response. Is the node running?"
  exit 1
fi

if ! echo "$BODY" | jq empty 2>/dev/null; then
  echo "Invalid JSON response:"
  echo "$BODY"
  exit 1
fi

if echo "$BODY" | jq -e '.error' >/dev/null 2>&1; then
  echo "RPC error:"
  echo "$BODY" | jq .
  exit 1
fi

if $RAW || [[ "$VERBOSE" == "0" ]]; then
  echo "$BODY" | jq .
  exit 0
fi

echo
echo "=== Block $TARGET ==="
echo

# Header summary when available
echo "$BODY" | jq -r '
  .result as $r |
  (if $r.height then "height:  " + ($r.height|tostring) else empty end),
  (if $r.hash then "hash:    " + ($r.hash|tostring) else empty end),
  (if $r.time then "time:    " + ($r.time|tostring) else empty end),
  (if $r.tx then "txs:     " + ($r.tx|length|tostring) else empty end)
'

echo
echo "Transactions:"
echo

if [[ "$VERBOSE" == "1" ]]; then
  echo "$BODY" | jq -r '
    if (.result.tx | type) != "array" then
      "(no tx list)"
    elif (.result.tx | length) == 0 then
      "  (none)"
    else
      .result.tx[] | "  " + (if type == "string" then . else (tojson) end)
    end
  '
else
  # verbosity 2: show txids + compact summary if objects
  echo "$BODY" | jq -r '
    if (.result.tx | type) != "array" then
      "(no tx list)"
    elif (.result.tx | length) == 0 then
      "  (none)"
    else
      .result.tx[] |
      if type == "string" then
        "  " + .
      elif type == "object" then
        "  " + (.txid // .hash // tojson)
      else
        "  " + (tojson)
      end
    end
  '
fi

echo
