local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';
local elasticsearch = import 'libs/elasticsearch.libsonnet';

local all() = {
  local name = 'k8s-elasticsearch',
  local namespace = 'elasticsearch',

  master_statefulset: elasticsearch(name, namespace, role = 'master') {
    spec+: {
      replicas: 3,
      template+: {
        spec+: {
          containers_+:: {
            default+: {
              resources: {
                limits: {
                  memory: '10Gi',
                },
                requests: {
                  cpu: '3',
                },
              },
              env_+:: {
                'ES_JAVA_OPTS': '-Xms8g -Xmx8g',
                'node.master': 'true',
                'node.data': 'false',
              },
            },
          },
        },
      },
      volumeClaimTemplates: [{
        metadata+: { name: 'data' },
        spec+: {
          storageClassName: 'standard',
          accessModes: ['ReadWriteOnce'],
          resources: { requests: { storage: '50Gi' } },
        },
      }],
    },
  },

  data_statefulset: elasticsearch(name, namespace, app = '%s-query' % name, role = 'data') {
    spec+: {
      template+: {
        spec+: {
          containers_+:: {
            default+: {
              env_+:: {
                'node.master': 'false',
                'node.data': 'true',
              },
            },
          },
        },
      },
      volumeClaimTemplates: [{
        metadata+: { name: 'data' },
        spec+: {
          storageClassName: 'standard',
          accessModes: ['ReadWriteOnce'],
          resources: { requests: { storage: '250Gi' } },
        },
      }],
    },
  },

  headless_service: ok.Service('%s-headless' % name, namespace) {
    spec+: {
      clusterIP: 'None',
      ports:[
        { port: 9200, protocol: 'TCP', targetPort: 'db', name: 'db' },
        { port: 9300, protocol: 'TCP', targetPort: 'transport', name: 'transport' },
      ],
      selector: { discovery: name },
    },
  },

  discovery_service: ok.Service('%s-discovery' % name, namespace) {
    metadata+: {
      annotations+: {
        'service.beta.kubernetes.io/aws-load-balancer-internal': 'true',
        'external-dns.alpha.kubernetes.io/hostname': '%s.%s.intor.io' % [name, cluster.global_name],
      },
    },
    spec+: {
      ports: $.headless_service.spec.ports,
      selector: { discovery: name },
      type: 'LoadBalancer',
      loadBalancerSourceRanges: ['10.0.0.0/8'],
    },
  },

  cross_cluster_service: ok.Service(name, namespace) {
    metadata+: {
      annotations+: {
        'service.beta.kubernetes.io/aws-load-balancer-internal': 'true',
        'external-dns.alpha.kubernetes.io/hostname': 'es-logging.%s.intor.io' % [cluster.global_name],
      },
    },
    spec+: {
      ports: $.headless_service.spec.ports,
      selector: { app: '%s-query' % name },
      type: 'LoadBalancer',
      loadBalancerSourceRanges: ['10.0.0.0/8'],
    },
  },
};

ok.List() {
  items_: all(),
}
