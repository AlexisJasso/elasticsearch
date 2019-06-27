#!/usr/bin/env bash
export  DIR=$(git rev-parse --show-toplevel) \
        CONTEXT=${1}

source "${DIR}/bin/es-clusters.sh"

for (( i = 0; i < ${#ES_NAMES[@]}; i++ ));
do
  (
    ES_CLUSTER="${ES_NAMES[$i]}"
    CONTEXT="${ES_CLUSTERS[$i]}"
    cd "${DIR}"

    echo "Validating ${ES_CLUSTER} Elasticsearch against ${CONTEXT}..."

    kubecfg validate \
      manifests/elasticsearch/*.jsonnet \
      manifests/curator/*.jsonnet \
      manifests/kibana/*.jsonnet \
      --jurl http://k8s-clusters.outreach.cloud/ \
      --jurl https://raw.githubusercontent.com/getoutreach/jsonnet-libs/master \
      --context ${CONTEXT} \
      -V cluster=${CONTEXT} \
      -V es-cluster=${ES_CLUSTER}
  )
done
