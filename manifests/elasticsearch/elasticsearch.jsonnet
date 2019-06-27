local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';
local utils = import '../libs/utils.libsonnet';
local elasticsearch = import '../libs/elasticsearch.libsonnet';
local es_clusters = import '../../es-clusters.libsonnet';
local es_cluster = utils.GetCluster(std.extVar('es-cluster'), es_clusters);

local all() = {
  local name            = es_cluster.name,
  local namespace       = es_cluster.namespace,
  local discovery_host  = '%s.%s.intor.io' % [name, cluster.global_name],
  local xcluster_host   = '%s.%s.intor.io' % [es_cluster.elasticsearch.service, cluster.global_name],

  master_statefulset: elasticsearch(
    name            = name,
    namespace       = namespace,
    role            = 'master',
    http_port       = es_cluster.elasticsearch.master.http_port,
    transport_port  = es_cluster.elasticsearch.master.transport_port,
  ) {
    spec+: {
      replicas: 3,
      template+: {
        spec+: {
          containers_+:: {
            default+: {
              resources+: es_cluster.elasticsearch.master.resources,
              env_+:: {
                'node.master': 'true',
                'node.data': 'false',
              } + es_cluster.elasticsearch.master.env,
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

  data_statefulset: elasticsearch(
    name            = name,
    namespace       = namespace,
    app             = '%s-query' % name,
    role            = 'data',
    http_port       = es_cluster.elasticsearch.data.http_port,
    transport_port  = es_cluster.elasticsearch.data.transport_port,
  ) {
    spec+: {
      replicas: es_cluster.elasticsearch.data.replicas,
      template+: {
        spec+: {
          containers_+:: {
            default+: {
              resources+: es_cluster.elasticsearch.data.resources,
              env_+:: {
                'node.master': 'false',
                'node.data': 'true',
              } + es_cluster.elasticsearch.data.env,
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
        { port: es_cluster.elasticsearch.data.http_port, protocol: 'TCP', targetPort: 'db', name: 'db' },
        { port: es_cluster.elasticsearch.data.transport_port, protocol: 'TCP', targetPort: 'transport', name: 'transport' },
      ],
      selector: { discovery: name },
    },
  },

  discovery_service: ok.Service('%s-discovery' % name, namespace) {
    metadata+: {
      annotations+: {
        'service.beta.kubernetes.io/aws-load-balancer-internal': 'true',
        'external-dns.alpha.kubernetes.io/hostname': discovery_host,
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
        'external-dns.alpha.kubernetes.io/hostname': xcluster_host,
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
