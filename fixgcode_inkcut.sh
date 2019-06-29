#!/bin/bash
# 2019 hadez@infuanfu.de
# see fix_inkcut_gcode.pl for details
#
# USAGE:
#   ./fixgcode_incut.sh <gcode file>

if [ ! -e "$1" ]; then
	echo "no file given, exiting"
	exit 1
fi

if [ "$2" != "" ]; then
	echo "only single file parameter allowed, exiting"
	exit 1
fi

$(dirname $0)/fixgcode.sh $1

dos2unix "$1"
tmp=$(mktemp)
cat "$1" | $(dirname $0)/fix_inkcut_gcode.pl > "$tmp"
mv "$tmp" "$1"

