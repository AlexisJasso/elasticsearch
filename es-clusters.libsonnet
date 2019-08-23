# Using recommendations as defined by Elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

[
  // ops.us-west-2 jaeger cluster
  {
    local this = self,
    name: 'jaeger-elasticsearch',
    namespace: 'jaeger',
    cluster: 'ops.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9201',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9201,
        transport_port: 9301,
        replicas: 3,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
      data: {
        http_port: 9201,
        transport_port: 9301,
        replicas: 12,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '500Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: null,
  },

  // Ops envoy cluster
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'ops.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9202',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 3,
        resources: {
          limits: {
            memory: '16Gi',
          },
          requests: {
            cpu: '2',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
        },
      },
      data: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '4',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: null,
  },

  // staging.us-west-2 envoy cluster
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'staging.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9202',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 3,
        resources: {
          limits: {
            memory: '16Gi',
          },
          requests: {
            cpu: '2',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
        },
      },
      data: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '4',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: ['%s-elasticsearch-to-ops.us-west-2' % this.elasticsearch.name],
  },

  // staging.us-east-2 envoy cluster
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'staging.us-east-2',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9202',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 3,
        resources: {
          limits: {
            memory: '16Gi',
          },
          requests: {
            cpu: '2',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
        },
      },
      data: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '4',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: ['%s-elasticsearch-to-staging.us-west-2' % this.elasticsearch.name],
  },

  // production.us-west-2 Envoy
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'production.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9202',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 3,
        resources: {
          limits: {
            memory: '16Gi',
          },
          requests: {
            cpu: '2',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
        },
      },
      data: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '4',
          },
        },
        storage: '500Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: ['%s-elasticsearch-to-staging.us-east-2' % this.elasticsearch.name],
  },

  // production.us-east-1 Envoy
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'production.us-east-1',
    curator: {
      name: '%s-curator' % this.name,
      http_port: '9202',
    },
    elasticsearch: {
      name: this.namespace,
      service: '%s-es' % this.namespace,
      master: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 3,
        resources: {
          limits: {
            memory: '16Gi',
          },
          requests: {
            cpu: '2',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
        },
      },
      data: {
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '4',
          },
        },
        storage: '500Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
    },
    kibana: {
      name: '%s-kibana' % this.namespace,
    },
    passed: ['%s-elasticsearch-to-production.us-west-2' % this.elasticsearch.name],
  },
]
