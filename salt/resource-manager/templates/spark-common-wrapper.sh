#!/usr/bin/env bash

# Find which script to call
CALLER_DIR="$(cd "`dirname "$0"`"; pwd)"
if [ "$CALLER_DIR" == "/usr/bin" ] || [ "$CALLER_DIR" == "/bin" ] || [ "$CALLER_DIR" == "{{ resource_manager_dir }}" ]; then
  # The wrapper (or master alternative) is the caller, so we can now call the original script.
  script=`basename "$0"`
  EXECUTABLE="$(update-alternatives --display "$script" | egrep -v '^/bin' | egrep -v '^/usr/bin' | egrep -o ^/.*"${script}" | head -n 1)"
  if [ "X$EXECUTABLE" == "X" ]; then
    echo "There is no alternative for $script"
    exit 1
  fi
else
  EXECUTABLE="/usr/bin/$(basename "$0")"
fi

# Set the queue in the argument list

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

# define the appropriate queue according to the policy
QUEUE=`{{ resource_manager_dir }}/spark-policy.sh ${REQUEST}`
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then 
  echo "Error: spark-policy returned exit $EXIT_CODE: $QUEUE"
  exit 2
fi

# assemble the arguments and call the function
if [ "X$QUEUE" != "X" ]; then
  KEEP=("--queue" "$QUEUE" "${KEEP[@]}")
fi 
set -- "${KEEP[@]}"

# Call the script with all the arguments.
echo "Executing: $EXECUTABLE $@"
exec "${EXECUTABLE}" "$@"
