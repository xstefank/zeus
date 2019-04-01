#!/bin/bash

readonly JENKINS_WORKSPACE=${JENKINS_WORKSPACE:-'/home/jboss/jenkins_workspace/workspace'}
readonly DRY_MODE=${DRY_MODE:-'false'}

if [ ! -d "${JENKINS_WORKSPACE}" ] ; then
  echo "No such directory: ${JENKINS_WORKSPACE}."
  exit 1
fi

if [ ! ${DRY_MODE} ] ; then 
  find "${JENKINS_WORKSPACE}"/*ws-cleanup* -mindepth 1 -mtime +7  -delete
else
  find "${JENKINS_WORKSPACE}"/*ws-cleanup* -mindepth 1 -mtime +7 -print
fi
