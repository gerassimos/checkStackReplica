#!/bin/bash



if [ $# -lt 1 ]
then
  echo "Usage: $0 "
  echo "<docker stack name>"
  exit 1
fi

#set -e # exit on error
stack_name=$1

checkStackReplica()
{
  local stack_name=$1
  check_status=0
  stack_services=$(docker stack services ${stack_name} | grep -v "ID")

  while read -r line; do
    service_name=$(echo "$line" | awk '{ print $2 }')
    service_replica=$(echo "$line" | awk '{ print $4 }')
    while IFS='/' read -ra REP_NR_ACTUAL_DESIRED ; do
       declare -i REP_NR_ACTUAL=${REP_NR_ACTUAL_DESIRED[0]}
       declare -i REP_NR_DESIRED=${REP_NR_ACTUAL_DESIRED[1]}
       if [ ${REP_NR_ACTUAL} -eq ${REP_NR_DESIRED} ]; then
         echo "Replica check OK ${service_name} ${REP_NR_ACTUAL} ${REP_NR_DESIRED}"
       else
         echo "Replica check FAILED ${service_name} ${REP_NR_ACTUAL} ${REP_NR_DESIRED}"
         check_status=1
       fi
     done <<< "$(echo -e "${service_replica}")"
  done <<< "$(echo -e "${stack_services}")"
  return ${check_status}
}

exit_code=0
for i in {1..100}; do
  checkStackReplica $stack_name
  exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    echo "retry $i SUCCESS"
    break
  else
    echo "retry $i FAILED"
    sleep 3
  fi
done

exit $exit_code


