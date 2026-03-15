#!/usr/bin/env fish
# Fish shell script example

set -l API_BASE "https://api.example.com"
set -l CACHE_DIR "$HOME/.cache/myapp"

function fetch_user
    set -l id $argv[1]
    set -l cache "$CACHE_DIR/user_$id.json"

    if test -f $cache
        echo "Cache hit" >&2
        cat $cache
        return
    end

    mkdir -p $CACHE_DIR
    curl -fsSL "$API_BASE/users/$id" | tee $cache
end

function greet_user
    set -l id $argv[1]
    set -l json (fetch_user $id)
    set -l name (echo $json | python3 -c "import sys,json;print(json.load(sys.stdin)['name'])")
    echo "Hello, $name!"
end

if test (count $argv) -lt 1
    echo "Usage: "(status filename)" <user_id>"
    exit 1
end

greet_user $argv[1]
