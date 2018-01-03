#!/usr/bin/env bash
# This code implements a user/group based queue placement policy.

define_queue ()
{
# See who is submitting the request
local REQUEST=$1
local USER_NAME=`id -un`
local USER_GROUPS=`id -Gn`

local MAP={{ map_file }}
if [ ! -f $MAP ]; then
  echo "$MAP file missing"
  exit 1
fi

QUEUE=''
# Read in the map tables
while read member queue; do
  [[ "$member" =~ ^#.* ]] && continue
  if [ "$member" == '*' ]; then
    QUEUE="$queue"
  else 
    user=`echo "$member" | awk -F':' '{print $1}'`
    group=`echo "$member" | awk -F':' '{print $2}'`
    if [ "X$user" == "X$USER_NAME" ]; then
      QUEUE="$queue"
    elif [ "X$user" == "X" ] && [ "X$group" != "X" ]; then
      if echo "$USER_GROUPS" | grep -q -w "$group" ; then
        QUEUE="$queue"
      fi
    fi
  fi
  if [ "X$QUEUE" != "X" ]; then 
    if [ "X$REQUEST" == "X$QUEUE" ] || [ "X$REQUEST" == "X" ] ; then
      # if this is the requested queue or no queue was requested, then we are done
      break;
    else 
      QUEUE=''
    fi
  fi
done < $MAP
}

define_queue $1
if [ "X$QUEUE" != "X" ]; then
  echo $QUEUE
  exit 0
else
  if [ "X$1" == "X" ]; then
    echo "Error: No matching rule."
    exit 2
  else
    echo "Error: No matching queue."
    exit 3
  fi
fi 
