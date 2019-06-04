local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';
local es_clusters = import '../../es-clusters.libsonnet';
local elasticsearch = import 'libs/elasticsearch.libsonnet';
local es_config = es_clusters[cluster.global_name];

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
                  memory: '20Gi',
                },
                requests: {
                  cpu: '3',
                },
              },
              env_+:: {
                'ES_JAVA_OPTS': '-Xms10g -Xmx10g',
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

  master_pdb: ok.PodDisruptionBudget('%s-%s' % [name, 'master'], namespace) {
    spec+: { maxUnavailable: 1 },
  },

  data_statefulset: elasticsearch(name, namespace, app = '%s-query' % name, role = 'data') {
    spec+: {
      replicas: es_config.data_node.replicas,
      template+: {
        spec+: {
          containers_+:: {
            default+: {
              resources+: es_config.data_node.resources,
              env_+:: {
                'node.master': 'false',
                'node.data': 'true',
              } + es_config.data_node.env,
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

  data_pdb: ok.PodDisruptionBudget('%s-%s' % [name, 'data'], namespace, app = '%s-query' % name) {
    spec+: { maxUnavailable: 1 },
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
