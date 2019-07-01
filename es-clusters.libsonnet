# Using recommendations as defined by Elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

[
  // ops.us-west-2 logging cluster
  {
    local this = self,
    name: 'k8s-elasticsearch',
    namespace: 'elasticsearch',
    cluster: 'ops.us-west-2',
    curator: {
      name: 'curator',
    },
    elasticsearch: {
      name: 'logging',
      service: 'es-logging',
      master: {
        http_port: 9200,
        transport_port: 9300,
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
        http_port: 9200,
        transport_port: 9300,
        replicas: 12,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: 'kibana',
    },
    passed: null,
  },

  // staging.us-east-2 logging cluster
  {
    local this = self,
    name: 'k8s-elasticsearch',
    namespace: 'elasticsearch',
    cluster: 'staging.us-east-2',
    curator: {
      name: 'curator',
    },
    elasticsearch: {
      name: 'logging',
      service: 'es-logging',
      master: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 3,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '8',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
      data: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 3,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: 'kibana',
    },
    passed: ['%s-elasticsearch-to-ops.us-west-2' % this.elasticsearch.name],
  },

  // staging.us-west-2 logging cluster
  {
    local this = self,
    name: 'k8s-elasticsearch',
    namespace: 'elasticsearch',
    cluster: 'staging.us-west-2',
    curator: {
      name: 'curator',
    },
    elasticsearch: {
      name: 'logging',
      service: 'es-logging',
      master: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 3,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '8',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
      data: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 3,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: 'kibana',
    },
    passed: ['%s-elasticsearch-to-staging.us-east-2' % this.elasticsearch.name],
  },

  // production.us-east-1 logging cluster
  {
    local this = self,
    name: 'k8s-elasticsearch',
    namespace: 'elasticsearch',
    cluster: 'production.us-east-1',
    curator: {
      name: 'curator',
    },
    elasticsearch: {
      name: 'logging',
      service: 'es-logging',
      master: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 3,
        resources: {
          limits: {
            memory: '32Gi',
          },
          requests: {
            cpu: '8',
          },
        },
        storage: '50Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms16g -Xmx16g',
        },
      },
      data: {
        http_port: 9200,
        transport_port: 9300,
        replicas: 5,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: 'kibana',
    },
    passed: ['%s-elasticsearch-to-staging.us-west-2' % this.elasticsearch.name],
  },

  // production.us-west-2 logging cluster
  {
    local this = self,
    name: 'k8s-elasticsearch',
    namespace: 'elasticsearch',
    cluster: 'production.us-west-2',
    curator: {
      name: 'curator',
    },
    elasticsearch: {
      name: 'logging',
      service: 'es-logging',
      master: {
        http_port: 9200,
        transport_port: 9300,
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
        http_port: 9200,
        transport_port: 9300,
        replicas: 24,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
        env: {
          'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
        },
      },
    },
    kibana: {
      name: 'kibana',
    },
    passed: ['%s-elasticsearch-to-production.us-east-1' % this.elasticsearch.name],
  },

  // ops.us-west-2 jaeger cluster
  {
    local this = self,
    name: 'jaeger-elasticsearch',
    namespace: 'jaeger',
    cluster: 'ops.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
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
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
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

  // staging.us-west-2 envoy cluster
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'staging.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
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
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
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

  // staging.us-east-2 envoy cluster
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'staging.us-east-2',
    curator: {
      name: '%s-curator' % this.name,
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
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
        resources: {
          limits: {
            memory: '64Gi',
          },
          requests: {
            cpu: '16',
          },
        },
        storage: '250Gi',
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

  // production.us-west-2 Envoy
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'production.us-west-2',
    curator: {
      name: '%s-curator' % this.name,
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
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
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

  // production.us-east-1 Envoy
  {
    local this = self,
    name: 'contour-elasticsearch',
    namespace: 'contour',
    cluster: 'production.us-east-1',
    curator: {
      name: '%s-curator' % this.name,
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
        http_port: 9202,
        transport_port: 9302,
        replicas: 5,
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
]
