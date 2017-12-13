#!/usr/bin/env bash

# Find which script to call
CALLER_DIR="$(cd "`dirname "$0"`"; pwd)"
if [ "$CALLER_DIR" == "/usr/bin" ]; then
  # Avoid loops.
  script=`basename "$0"`
  EXECUTABLE="$(update-alternatives --list "$script" | fgrep -v '/usr/bin' | head -n 1)"
  if [ "X$EXECUTABLE" == "X" ]; then
    echo "There is no alternative for $script"
    exit
  fi
else
  EXECUTABLE="/usr/bin/$(basename "$0")"
fi

# Set the queue in the argument list
. {{ resource_manager_dir }}/spark-policy.sh

# Call the script with all the arguments.
echo "Executing: $EXECUTABLE $@"
exec "${EXECUTABLE}" "$@"
