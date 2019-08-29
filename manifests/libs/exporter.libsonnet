local ok = import 'kubernetes/outreach.libsonnet';
local es_ns = 'elasticsearch';

{
  newExporter(suffix, address)::
    local all(
      app = "es-exporter-%s" % suffix,
      namespace=es_ns, 
      name = "es-exporter-%s" % suffix,
      ) = {
      local exporter = self,
      deployment: ok.Deployment(name, namespace, app) {
        spec+: {
          replicas: 1,
          strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
              maxSurge: 1,
              maxUnavailable: 0,
            },
          },
          template+: {
            metadata+: {
              labels+: {
                'external_elasticsearch_cluster': "%s" % suffix,
              },
            },
            spec+: {
              containers+: [
                ok.Container(name) {
                  image: "justwatch/elasticsearch_exporter:1.1.0",
                  imagePullPolicy: "IfNotPresent",
                  command: [
                    "elasticsearch_exporter",
                    "--es.uri="+address,
                    "--es.all",
                    "--es.indices",
                    "--es.shards",
                    "--es.cluster_settings",
                    "--es.snapshots",
                    "--es.timeout=30s",
                    "--web.listen-address=:9108",
                    "--web.telemetry-path=/metrics"                
                  ],
                  resources: {
                    limits: {
                      memory: "2Gi",
                      cpu: "1"
                    },
                    requests: {
                      cpu: "400m",
                    },
                  },
                  livenessProbe: {
                    httpGet: {
                      path: "/health",
                      port: 9108,
                    },
                    initialDelaySeconds: 30,
                    timeoutSeconds: 10
                  },
                  readinessProbe: {
                    httpGet: {
                      path: "/health",
                      port: 9108
                    },
                    initialDelaySeconds: 10,
                    timeoutSeconds: 10
                  },
                  ports_:: {
                    http: {containerPort: 9108, protocol: 'TCP'},
                  },
                  securityContext: {
                    readOnlyRootFilesystem: true,
                  },

                },
              ],
              restartPolicy: "Always",
            },
          },
        },
      },
      service: ok.Service(name, namespace, app) {
        target_pod:: exporter.deployment.spec.template,
      },
      servicemonitor: ok.ServiceMonitor(name, namespace) {
        target_service:: exporter.service,
        spec+: {
          endpoints_+:: {
            http+: {
              interval: '2m',
              scrapeTimeout: '2m',
            },
          },
          podTargetLabels: [
            'external_elasticsearch_cluster',
          ],
        },
      },
    };
  all()
}