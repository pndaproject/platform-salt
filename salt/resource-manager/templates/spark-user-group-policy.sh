#!/usr/bin/env bash
# This code implements a user/group based queue placement policy.

MAP={{ map_file }}
REQUEST=''

KEEP=()
# Find the requested queue
# and keep all other the options
while [[ $# -gt 0 ]]
do
  case "${1}" in
  --queue)
      REQUEST="${2}"
      shift 2
      ;;
  *)
      KEEP+=("${1}")
      shift
      ;;
  esac
done

# See who is submitting the request
USER_NAME=`id -un`
USER_GROUPS=`id -Gn`

if [ ! -f $MAP ]; then
  echo "$MAP file missing"
  exit 2
fi

TARGET=''
# Read in the map tables
while read member queue; do
  [[ "$member" =~ ^#.* ]] && continue
  user=`echo "$member" | awk -F':' '{print $1}'`
  group=`echo "$member" | awk -F':' '{print $2}'`
  if [ "X$user" == "X$USER_NAME" ]; then
    TARGET="$queue"
  elif [ "X$group" != "X" ]; then
    if echo "$USER_GROUPS" | grep -q -w "$group" ; then
      TARGET="$queue"
    fi
  fi
  if [ "X$TARGET" != "X" ] && [ "X$REQUEST" == "X$TARGET" ]; then
    # if this is the requested queue, then we are done
    break;
  fi
done < $MAP

# Overwrite any queue setting
KEEP+=("--queue" "$TARGET")
set -- "${KEEP[@]}"
echo "-------Starting with ${KEEP[@]}"
