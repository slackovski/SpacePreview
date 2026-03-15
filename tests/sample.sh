#!/usr/bin/env bash
set -euo pipefail

API_BASE="https://api.example.com"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/myapp"

fetch_user() {
  local id="$1"
  local cache_file="$CACHE_DIR/user_${id}.json"

  if [[ -f "$cache_file" ]]; then
    echo "Cache hit: $cache_file" >&2
    cat "$cache_file"
    return
  fi

  mkdir -p "$CACHE_DIR"
  curl -fsSL "$API_BASE/users/$id" | tee "$cache_file"
}

print_user() {
  local id="$1"
  local json
  json="$(fetch_user "$id")"
  local name
  name="$(echo "$json" | python3 -c "import sys,json; print(json.load(sys.stdin)['name'])")"
  echo "Hello, $name!"
}

main() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <user_id>" >&2
    exit 1
  fi
  print_user "$1"
}

main "$@"
