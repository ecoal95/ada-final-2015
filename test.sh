#!/bin/bash

EXECUTABLE=./obj/final

if [ $# -lt 2 ]; then
  echo "Usage: $0 seconds expected_iterations [--no-prompt]"
  exit 1
fi

ensure_numeric() {
  case "$1" in
    [0-9][0-9]*) return 0;;
    *) echo "$0: Expected numeric argument, found $1"; exit 1 ;;
  esac
}

ensure_numeric "$1"
ensure_numeric "$2"

no_prompt=0
if [ "$3" = "--no-prompt" ]; then
  no_prompt=1
fi

if [ ! -f "$EXECUTABLE" ]; then
  echo "$0: executable $EXECUTABLE not found";
  exit 1
fi

time_to_run="$1"
expected="$2"
file=`mktemp`
echo "$0: testing during $time_to_run seconds, expecting $expected iterations."
echo "$0: dumping data to $file"
timeout "$time_to_run" "$EXECUTABLE" > "$file"

lines=$(grep 'ESTABLE\|PELIGRO' "$file" | wc -l)
echo "$0: finished, got $lines lines, expected $expected"
if [ $lines -ne $expected ]; then
  echo "Failure!"
  exit 1;
fi

echo "Ok!"

if [ $no_prompt -eq 0 ]; then
  echo "$0: Do you want the file to be removed? [Y/n]"
  read -p "$0: " option
  case "$option" in
    Y|y) rm "$file" ;;
    *) ;;
  esac
fi
