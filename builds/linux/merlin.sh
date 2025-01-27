#!/bin/sh
echo -ne '\033c\033]0;merlin_vass\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/merlin.x86_64" "$@"
