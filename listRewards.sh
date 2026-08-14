#!/usr/bin/env bash

show_individual=false
show_total=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--individual)
      show_individual=true
      shift
      ;;
    -t|--total)
      show_total=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-i|--individual] [-t|--total]"
      echo "  -i, --individual   Show each position reward"
      echo "  -t, --total        Show total rewards"
      echo "  (default: both)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if ! $show_individual && ! $show_total; then
  show_individual=true
  show_total=true
fi

JSON=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"wallet_staking_positions","params":[],"id":1}' \
  http://127.0.0.1:8232/)

if $show_individual; then
  echo
  echo "Individual staking rewards:"
  echo "$JSON" | jq -r '.result.active[][] | ((.latest_val - .initial_val) / 1e8 | "  \(.) ZEC")'
fi

if $show_total; then
  echo
  TOTAL=$(echo "$JSON" | jq '([.result.active[][] | (.latest_val - .initial_val)] | add) / 1e8')
  echo "Total: ${TOTAL} ZEC"
  echo
fi
