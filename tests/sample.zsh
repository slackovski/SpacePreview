#!/usr/bin/env zsh
# Zsh script example
setopt ERR_EXIT PIPE_FAIL

typeset -A CONFIG=(
  api_base "https://api.example.com"
  cache_dir "${HOME}/.cache/myapp"
)

function fetch_user() {
  local id=$1
  local cache="${CONFIG[cache_dir]}/user_${id}.json"

  if [[ -f $cache ]]; then
    print "Cache hit" >&2
    cat $cache
    return
  fi

  mkdir -p ${CONFIG[cache_dir]}
  curl -fsSL "${CONFIG[api_base]}/users/${id}" | tee $cache
}

function main() {
  local id=${1:-1}
  local json=$(fetch_user $id)
  local name=$(print $json | python3 -c "import sys,json;print(json.load(sys.stdin)['name'])")
  print "Hello, ${name}!"
}

main $@
