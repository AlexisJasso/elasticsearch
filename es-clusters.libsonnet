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
]
