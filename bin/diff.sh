#!/usr/bin/env bash
export  DIR=$(git rev-parse --show-toplevel) \
        CONTEXT=${1}

source "${DIR}/bin/es-clusters.sh"

# Diff will "error" any time it finds differences
set +e

for (( i = 0; i < ${#ES_NAMES[@]}; i++ ));
do
  (
    ES_CLUSTER="${ES_NAMES[$i]}"
    CONTEXT="${ES_CLUSTERS[$i]}"
    cd "${DIR}"

    echo "Diff ${ES_CLUSTER} Elasticsearch against ${CONTEXT}..."

    kubecfg diff \
      manifests/elasticsearch/*.jsonnet \
      manifests/curator/*.jsonnet \
      manifests/kibana/*.jsonnet \
      --diff-strategy=subset \
      --jurl http://k8s-clusters.outreach.cloud/ \
      --jurl https://raw.githubusercontent.com/getoutreach/jsonnet-libs/master \
      --context ${CONTEXT} \
      -V cluster=${CONTEXT} \
      -V es-cluster=${ES_CLUSTER}
  )
done
