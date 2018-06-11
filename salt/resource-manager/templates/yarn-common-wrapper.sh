#!/usr/bin/env bash

# Find which script to call
CLI=`basename "$0"`

if [ $CLI == "hive" ] || [ $CLI == "beeline" ]; then
#--hiveconf tez.queue.name=dev
  PROP=('--hiveconf' 'tez.queue.name')
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
  KEEP=("${PROP[0]}" "$PROPVALUE" "${KEEP[@]}")
fi
set -- "${KEEP[@]}"

# Call the script with all the arguments.
[[ "X$WRAPPED_SPARK_HOME" != 'X' ]] && export SPARK_HOME=$WRAPPED_SPARK_HOME
REM={{ resource_manager_path }}/bin
REM=${REM//\//\\/}
PATH=${PATH/$REM:/}
echo "Setting PATH=$PATH"
echo "Executing: $CLI $@"
exec "$CLI" "$@"
