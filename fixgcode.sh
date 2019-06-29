#!/bin/bash
# hadez@infuanfu.de
# fix jscut.org gcode comment format so it works with uccnc
#
# jscut: "CMD; COMMENT"
# uccnc: "CMD (COMMENT)"
#
# USAGE:
#   ./fixgcode.sh <gcode file>

if [ ! -e "$1" ]; then
	echo "no file given, exiting"
	exit 1
fi

if [ "$2" != "" ]; then
	echo "only single file parameter allowed, exiting"
	exit 1
fi

dos2unix "$1"
tmp=$(mktemp)
cat "$1" | perl -pe 'm/^(.*?)(?:;(.*))?$/; $_="$1$/"; $_="$1 ($2)$/" if defined $2;' > "$tmp"
mv "$tmp" "$1"

