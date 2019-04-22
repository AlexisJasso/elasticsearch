local ok = import 'kubernetes/outreach.libsonnet';
local cluster = ok.cluster;

local all(name, namespace) = {
  statefulset: ok.StatefulSet(name, namespace, app=name) {
    spec+: {
      replicas: 3,
      serviceName: 'es',
      template+: {
        spec+: {
          hostNetwork: true,
          serviceAccountName: name,
          securityContext: {
            fsGroup: 1000,
            runAsUser: 1000,
            runAsNonRoot: true,
          },
          affinity: {
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
                  ],
                  matchExpressions: [{
                    key: 'outreach.io/nodepool',
                    operator: 'In',
                    values: nodepools,
                  }],
                }],
              },
            },
            podAntiAffinity: {
              preferredDuringSchedulingIgnoredDuringExecution: [{
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'name',
                        operator: 'In',
                        values: [ name ],
                      },
                    ],
                  },
                  topologyKey: 'failure-domain.beta.kubernetes.io/zone',
                },
              weight: 100,
              }],
              // Ensure we don't run replicas on the same host
              requiredDuringSchedulingIgnoredDuringExecution: [{
                labelSelector: {
                  matchExpressions: [
                    {
                      key: 'name',
                      operator: 'In',
                      values: [ name ],
                    },
                  ],
                },
                topologyKey: 'kubernetes.io/hostname',
              }],
            },
          },
          tolerations: [{
            key: 'dedicated',
            operator: 'Equal',
            value: 'monitoring',
            effect: 'NoSchedule',
          }],
          containers: [
            ok.Container(name) {
              image: 'docker.elastic.co/elasticsearch/elasticsearch-oss:6.6.1',
              resources: {
                limits: {
                  memory: '16Gi',
                },
                requests: {
                  cpu: '4',
                },
              },
              ports: [
                { name: 'db', protocol: 'TCP', containerPort: 9200, },
                { name: 'transport', protocol: 'TCP', containerPort: 9300, },
              ],
              volumeMounts: [
                { name: 'data', mountPath: '/usr/share/elasticsearch/data', },
              ],
              env: [
                { name: 'network.tcp.keep_alive', value: 'true', },
                { name: 'network.host', value: '0.0.0.0', },
                { name: 'network.publish_host', value: '_eth0_', },
                { name: 'thread_pool.write.queue_size', value: '2000', },
                { name: 'transport.ping_schedule', value: '5s', },
                { name: 'ingest-geoip.enabled', value: 'false', },
                { name: 'ES_JAVA_OPTS', value: '-Xms13g -Xmx13g', },
                { name: 'NAMESPACE', value: namespace, },
                { name: 'discovery.zen.ping.unicast.hosts', value: 'es-logging.<%= cluster.global_name %>.intor.io', },
              ],
            },
          ],
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
      volumeClaimTemplates+: [{
        metadata: {
          name: 'data',
        },
        spec+: {
          storageClassName: 'standard',
          accessModes: [ 'ReadWriteOnce' ],
          resources+: {
            requests+: {
              storage: '250Gi',
            },
          },
        },
      }],
    },
  },
};

ok.List() {
  items_: all('elasticsearch-logging', 'monitoring'),
}
