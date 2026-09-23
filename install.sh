#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

find . -type f -name '.*' -o -type f -path './.config/*' | grep -v '^\./\.git/' | while read -r f; do
    f="${f#./}"
    mkdir -p "$HOME/$(dirname "$f")"
    ln -sfn "$PWD/$f" "$HOME/$f"
    echo "$HOME/$f -> $PWD/$f"
done
