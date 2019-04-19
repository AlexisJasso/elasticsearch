local ok = import 'kubernetes/outreach.libsonnet';

local all(
  name = 'es-prom-exporter',
  namespace = std.extVar('namespace'),
) = { 
  deployment: ok.Deployment(name, namespace) {
    spec+: {
      replicas: 1,
      template+: {
        metadata+: {
          annotations+: {
            'prometheus.io/port': '9114',
            'prometheus.io/scrape': 'true',
          },
        },
        spec+: {
          securityContext: {
            runAsNonRoot: true,
            runAsUser: 1000
          },
          containers+: [
            ok.Container(name) {
              command: [
                '/bin/elasticsearch_exporter',
                '-es.uri=http://elasticsearch-logging:9200',
                '-es.all=true',
                '-web.listen-address=:9114',
              ],
              image: 'justwatch/elasticsearch_exporter:1.0.2',
              ports: [
                { containerPort: 9114, name: 'metrics' },
              ],
              livenessProbe: {
                httpGet: { path: '/health', port: 9114 },
                initialDelaySeconds: 30,
                timeoutSeconds: 10,
              },
              readinessProbe: {
                httpGet: { path: '/health', port: 9114 },
                initialDelaySeconds: 10,
                timeoutSeconds: 10,
              },
              resources: {
                limits: {
                  memory: '128Mi',
                },
                requests: {
                  cpu: '100m',
                },
              },
              securityContext: {
                readOnlyRootFilesystem: true,
                capabilities: {
                  drop: [
                    'SETPCAP',
                    'MKNOD',
                    'AUDIT_WRITE',
                    'CHOWN',
                    'NET_RAW',
                    'DAC_OVERRIDE',
                    'FOWNER',
                    'FSETID',
                    'KILL',
                    'SETGID',
                    'SETUID',
                    'NET_BIND_SERVICE',
                    'SYS_CHROOT',
                    'SETFCAP',
                  ],
                },
              },
            },
          ],
        },
      },
    },
  },
};

ok.List() { items_+: all() }
