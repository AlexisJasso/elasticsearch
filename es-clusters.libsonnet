# Using recommendations as defined by Elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

{
  'ops.us-west-2': {
    data_node: {
      replicas: 12,
      resources: {
        limits: {
          memory: '64Gi',
        },
        requests: {
          cpu: '16',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
      },
    },
  },
  'staging.us-west-2': {
    data_node: {
      replicas: 5,
      resources: {
        limits: {
          memory: '64Gi',
        },
        requests: {
          cpu: '16',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
      },
    },
  },
  'staging.us-east-2': {
    data_node: {
      replicas: 5,
      resources: {
        limits: {
          memory: '64Gi',
        },
        requests: {
          cpu: '16',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
      },
    },
  },
  'production.us-east-1': {
    data_node: {
      replicas: 5,
      resources: {
        limits: {
          memory: '64Gi',
        },
        requests: {
          cpu: '16',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
      },
    },
  },
  'production.us-west-2': {
    data_node: {
      replicas: 12,
      resources: {
        limits: {
          memory: '64Gi',
        },
        requests: {
          cpu: '16',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
      },
    },
  },
}
