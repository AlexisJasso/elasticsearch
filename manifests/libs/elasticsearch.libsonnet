local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';

function(name, namespace, app = name, role = 'all', http_port = 9200, transport_port = 9300)
  ok.StatefulSet('%s-%s' % [name, role], namespace, app) {
    local headless_service = '%s-headless' % name,

    spec+: {
      replicas: 3,
      serviceName: headless_service,
      template+: {
        metadata+: {
          annotations+: {
            'prometheus.io/port': '9114',
            'prometheus.io/scrape': 'true',
          },
          labels+: {
            service: 'elasticsearch',
            discovery: name,
          },
        },
        spec+: {
          hostNetwork: true,
          securityContext: {
            fsGroup: 1000,
            runAsUser: 1000,
            runAsNonRoot: true,
          },
          affinity: {
            podAntiAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: [
                {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'service',
                        operator: 'In',
                        values: [
                          'elasticsearch',
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              ],
            },
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [{
                  local nodepools = [
                    'monitoring',
                    'monitoring-large',
                    'monitoring-xlarge',
                    'monitoring-2xlarge',
                    'monitoring-4xlarge',
                    'monitoring-8xlarge',
                    'monitoring-16xlarge',
                    'monitoring-24xlarge',
                  ],
                  matchExpressions: [{
                    key: 'outreach.io/nodepool',
                    operator: 'In',
                    values: nodepools,
                  }],
                }],
              },
            },
          },
          tolerations: [{
            key: 'dedicated',
            operator: 'Equal',
            value: 'monitoring',
            effect: 'NoSchedule',
          }],
          containers_:: {
            default: ok.Container('es') {
              image: 'docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.2',
              resources: {
                limits: {
                  memory: '64Gi',
                },
                requests: {
                  cpu: '6',
                },
              },
              ports: [
                { name: 'db', protocol: 'TCP', containerPort: http_port, },
                { name: 'transport', protocol: 'TCP', containerPort: transport_port, },
              ],
              volumeMounts: [
                { name: 'data', mountPath: '/usr/share/elasticsearch/data', },
              ],
              env_+:: {
                'http.port': '%s' % http_port,
                'transport.tcp.port': '%s' % transport_port,
                'ES_JAVA_OPTS': '-Xms32g -Xmx32g',
                'NAMESPACE': namespace,
                'network.tcp.keep_alive': 'true',
                'network.host': '0.0.0.0',
                'network.publish_host': '_eth0_',
                'thread_pool.bulk.queue_size': '2000',
                'thread_pool.write.queue_size': '2000',
                'transport.ping_schedule': '5s',
                'ingest-geoip.enabled': 'false',
                'discovery.zen.minimum_master_nodes': '2',
                'discovery.zen.ping.unicast.hosts': '%s.%s.intor.io' % [name, cluster.global_name],
                'cluster.name': '%s-%s-%s' % [name, cluster.environment, cluster.region],
                'node.name': ok.FieldRef('metadata.name'),
              },
            },
            exporter: ok.Container('exporter') {
              image: 'justwatch/elasticsearch_exporter:1.0.2',
              command: [
                '/bin/elasticsearch_exporter',
                '-es.uri=http://localhost:%s' % http_port,
                '-web.listen-address=:9114',
              ],
              resources: {
                limits: {
                  memory: '100Mi',
                },
                requests: {
                  cpu: '25m',
                },
              },
              ports: [
                { name: 'metrics', protocol: 'TCP', containerPort: 9114, },
              ],
            },
          },
          initContainers: [
            ok.Container('elasticsearch-logging-init') {
              image: 'alpine:3.6',
              command: [ "/sbin/sysctl", "-w", "vm.max_map_count=262144" ],
              securityContext: {
                privileged: true,
              },
            },
          ],
        },
      },
    },
  }
