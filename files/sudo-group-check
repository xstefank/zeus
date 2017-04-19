#!/bin/bash

status=0
for user in $(ls /etc/sudoers.d/ -1)
do 
   if [ "${user}" != "50_vdsm" ]; then
     id "${user}" | grep -e '1000(jboss-set)' 2>&1 > /dev/null
     if [ "${?}" -ne 0 ]; then
       echo "${user} does not belong to the jboss-set group, any sudo command will fail"
       status=1
     fi
  fi
done
exit "${status}"
