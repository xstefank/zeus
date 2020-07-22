#!/bin/bash
set -eo pipefail

readonly CONTAINER_NAME=${1}

if [ -z "${CONTAINER_NAME}" ]; then
  echo "No container provided, this script $(basename "${0}") requires a container as input"
  exit 1
fi

docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2> /dev/null | grep -e 'true' -q
