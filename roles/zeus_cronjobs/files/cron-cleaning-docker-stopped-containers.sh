#!/bin/bash

date '+%Y/%m/%d-%H:%M' 
for container in $(docker ps --filter "status=exited"  | sed -e 's/^\([^ ]*\).*$/\1/' | sed -e '/CONTAINER/d' );
do
  echo -n "Removing container $(docker inspect --format "{{ .Name}}" ${container}): "
  docker rm "${container}"
  echo 'Done.'
done
