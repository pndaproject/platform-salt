#!/usr/bin/env bash

# Find which script to call
CALLER_DIR="$(cd "`dirname "$0"`"; pwd)"
CLI=`basename "$0"`
if [ "$CALLER_DIR" == "/usr/bin" ] || [ "$CALLER_DIR" == "/bin" ] || [ "$CALLER_DIR" == "{{ resource_manager_path }}" ]; then
  # The wrapper (or master alternative) is the caller, so we can now call the original script.
  EXECUTABLE="$(update-alternatives --display "$CLI" | egrep -v '^/bin' | egrep -v '^/usr/bin' | egrep -v '^{{ resource_manager_path }}' | egrep -o ^/.*"$CLI" | head -n 1)"
  if [ "X$EXECUTABLE" == "X" ]; then
    echo "There is no alternative for $CLI"
    exit 1
  fi
else
  EXECUTABLE="/usr/bin/$CLI"
fi

if [ $CLI == "hive" ] || [ $CLI == "beeline" ]; then
#--hiveconf tez.queue.name=dev
  PROP=('--hiveconf' 'tez.queue.name')
elif [ $CLI == "flink" ] || [ $CLI == "pyflink.sh" ]; then 
  PROP=('-yqu' '')
else
  PROP=('--queue' '')
fi

# Set the queue in the argument list

REQUEST=''
KEEP=()
# Find the requested queue
# and keep all other the options
while [[ $# -gt 0 ]]
do
  case "$1" in
    ${PROP[0]})
      if [ "X${PROP[1]}" == "X" ]; then
        REQUEST="$2"
        shift 2
      else
        local MYARR
        IFS='=' read -ra MYARR <<< "$2"
        if [ "${PROP[1]}" == "${MYARR[0]}" ]; then
          REQUEST="${MYARR[1]}"
          shift 2
        else 
          KEEP+=("$1")
          shift
        fi
      fi 
      ;;
    # handlling long option argument of flink's yarn-queue
    # in case the user provides it
    --yarnqueue)
        REQUEST="$2"
        shift 2
      ;;
    # Handling short option argument of flink's start-scala-shell
    -qu)
	REQUEST="$2"
        shift 2
      ;;
    *)
      KEEP+=("$1")
      shift
      ;;
  esac
done

# define the appropriate queue according to the policy
QUEUE=`{{ policy_file_link }} $REQUEST`
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "Warning: yarn-policy returned exit $EXIT_CODE:  $QUEUE" >> {{ log_file }}
  QUEUE=''
fi

# assemble the arguments and call the function
if [ "X$QUEUE" != "X" ]; then
  if [ "X${PROP[1]}" != "X" ]; then
    PROPVALUE="${PROP[1]}=$QUEUE"
  else
    PROPVALUE=$QUEUE
  fi
  # Reorg arguments for flink applications
  if [ $CLI == "flink" ] || [ $CLI == "pyflink.sh" ] || [ $CLI == "start-scala-shell.sh" ]; then
     KEEP=("${KEEP[0]}"  "${PROP[0]}" "$PROPVALUE" "${KEEP[@]:1}")
  else
     KEEP=("${PROP[0]}" "$PROPVALUE" "${KEEP[@]}")
  fi
fi
set -- "${KEEP[@]}"

# Call the script with all the arguments.
[[ "X$WRAPPED_SPARK_HOME" != 'X' ]] && export SPARK_HOME=$WRAPPED_SPARK_HOME
echo "Executing: $EXECUTABLE $@"
exec "$EXECUTABLE" "$@"
