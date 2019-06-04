# Using recommendations as defined by Elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

{
  'ops.us-west-2': {
    master_node: {
      replicas: 3,
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
    master_node: {
      replicas: 3,
      resources: {
        limits: {
          memory: '32Gi',
        },
        requests: {
          cpu: '8',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
      },
    },
    data_node: {
      replicas: 3,
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
    master_node: {
      replicas: 3,
      resources: {
        limits: {
          memory: '32Gi',
        },
        requests: {
          cpu: '8',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
      },
    },
    data_node: {
      replicas: 3,
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
    master_node: {
      replicas: 3,
      resources: {
        limits: {
          memory: '32Gi',
        },
        requests: {
          cpu: '8',
        },
      },
      env: {
        'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
      },
    },
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
    master_node: {
      replicas: 3,
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
    data_node: {
      replicas: 24,
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
