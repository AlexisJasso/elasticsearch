#!/usr/bin/env bash
root_dir=$(git rev-parse --show-toplevel)

if [ -z "${1}" ]; then
  CLUSTER='ops.us-west-2'
else
  CLUSTER=${1}
fi

(
  cd "${root_dir}"

  kubecfg validate ci_cd/kubernetes/*.jsonnet \
  --jurl http://k8s-clusters.outreach.cloud/ \
  --jurl https://raw.githubusercontent.com/getoutreach/jsonnet-libs/master \
  --context ${CLUSTER} \
  -V cluster=${CLUSTER}
)
