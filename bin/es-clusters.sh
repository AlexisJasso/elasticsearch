#!/usr/bin/env bash	
set -e

export JSONNET=$(jsonnet ${DIR}/es-clusters.libsonnet)

if [ "${CONTEXT}" != "" ]; then
  export ES_NAMES=($(echo ${JSONNET} | jq -r --arg CONTEXT "${CONTEXT}" '.[] | select(.cluster == $CONTEXT).name'))
  export ES_CLUSTERS=($(echo ${JSONNET} | jq -r --arg CONTEXT "${CONTEXT}" '.[] | select(.cluster == $CONTEXT).cluster'))
else
  export ES_NAMES=($(echo ${JSONNET} | jq -r '.[].name'))
  export ES_CLUSTERS=($(echo ${JSONNET} | jq -r '.[].cluster'))
fi
