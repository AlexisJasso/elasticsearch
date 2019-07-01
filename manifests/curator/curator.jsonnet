local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';
local utils = import '../libs/utils.libsonnet';
local es_clusters = import '../../es-clusters.libsonnet';
local es_cluster = utils.GetCluster(std.extVar('es-cluster'), es_clusters);

local all() = {
  local name          = es_cluster.curator.name,
  local namespace     = es_cluster.namespace,
  local xcluster_host = '%s.%s.intor.io' % [es_cluster.elasticsearch.service, cluster.global_name],

  cronjob: ok.CronJob(name, namespace) {
    spec+: {
      concurrencyPolicy: 'Forbid',
      jobTemplate+: {
        spec+: {
          template+: {
            spec+: {
              containers: [
                {
                  command: [
                    "curator",
                    "--config",
                    "/var/curator/config/config.yaml",
                    "/var/curator/action/action_file.yaml",
                  ],
                  env: [
                    { name: 'ELASTIC_HOST', value: xcluster_host },
                    { name: 'ELASTIC_PORT', value: '9200' },
                    { name: 'LOGLEVEL', value: 'INFO' },
                    { name: 'RETENTION_DAYS', value: '7' },
                  ],
                  image: 'registry.outreach.cloud/curator:0.9.0',
                  name: 'curator',
                  volumeMounts: [
                    { name: '%s-config' % name, mountPath: '/var/curator/config' },
                    { name: '%s-action' % name, mountPath: '/var/curator/action' },
                  ],
                },
              ],
              volumes: [
                { name: '%s-config' % name, configMap: { name: '%s-config' % name } },
                { name: '%s-action' % name, configMap: { name: '%s-action' % name } },
              ],
              restartPolicy: 'OnFailure',
            },
          },
        },
      },
      schedule: '1 7 * * *',
    },
  },

  config_file: ok.ConfigMap('%s-config' % name, namespace) {
    data: {
      'config.yaml': |||
        client:
          hosts: ${ELASTIC_HOST}
          port: ${ELASTIC_PORT}
        
        logging:
          loglevel: ${LOGLEVEL}
          logfile:
      |||,
    },
  },

  action_file: ok.ConfigMap('%s-action' % name, namespace){
    data: {
      'action_file.yaml': |||
        actions:
          1:
            action: delete_indices
            description: >-
              Delete old indices
            options:
              ignore_empty_list: True
            filters:
            - filtertype: pattern
              kind: prefix
              value: logstash-
            - filtertype: age
              source: name
              direction: older
              timestring: '%Y.%m.%d'
              unit: days
              unit_count: ${RETENTION_DAYS:30}
          2:
            action: delete_indices
            description: >-
              Delete old metricbeat indices
            options:
              ignore_empty_list: True
            filters:
            - filtertype: pattern
              kind: prefix
              value: metricbeat-
            - filtertype: age
              source: name
              direction: older
              timestring: '%Y.%m.%d'
              unit: days
              unit_count: ${RETENTION_DAYS:30}
          3:
            action: delete_indices
            description: >-
              Delete future dated indices
            options:
              ignore_empty_list: True
            filters:
            - filtertype: pattern
              kind: prefix
              value: logstash-
            - filtertype: period
              period_type: relative
              source: name
              range_from: 1
              range_to: 10000
              timestring: '%Y.%m.%d'
              unit: days
          4:
            action: delete_indices
            description: >-
              Delete old contour indices
            options:
              ignore_empty_list: True
            filters:
            - filtertype: pattern
              kind: prefix
              value: logstash-contour
            - filtertype: age
              source: name
              direction: older
              timestring: '%Y.%m.%d'
              unit: days
              unit_count: 1
          5:
            action: delete_indices
            description: >-
              Delete old jaeger span indices
            options:
              ignore_empty_list: True
            filters:
            - filtertype: pattern
              kind: prefix
              value: jaeger-span
            - filtertype: age
              source: name
              direction: older
              timestring: '%Y.%m.%d'
              unit: days
              unit_count: 3
      |||,
    },
  },
};

ok.List() { items_+: all() }
