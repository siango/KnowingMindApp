#!/usr/bin/env bash
# termux_lib.sh — common functions for one-shot Termux scripts

ensure_pkg(){ pkg install -y "$@" >/dev/null 2>&1 || true; }
git_sync(){ repo=$1; branch=$2; path=$3;
  [ -d "$path/.git" ] && (cd $path && git fetch && git reset --hard origin/$branch) || git clone -b $branch $repo $path;
}
get_secret(){ KEY=$1; ~/.secrets_toolkit/get_secret.sh $KEY; }
health_check(){ url=$1; curl -fsSL --max-time 10 $url >/dev/null && echo "OK" || echo "FAIL"; }
