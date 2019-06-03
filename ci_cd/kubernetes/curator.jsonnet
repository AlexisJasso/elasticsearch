local ok = import 'kubernetes/outreach.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';

local all() = {
  local namespace = 'elasticsearch',

  cronjob: {
    apiVersion: 'batch/v1beta1',
    kind: 'CronJob',
    metadata: {
      name: 'curator',
      namespace: namespace,
    },
    spec: {
      concurrencyPolicy: 'Forbid',
      jobTemplate: {
        spec: {
          template: {
            spec: {
              containers: [
                {
                  command: [
                    "curator",
                    "--config",
                    "/var/curator/config/config.yaml",
                    "/var/curator/action/action_file.yaml",
                  ],
                  env: [
                    { name: 'ELASTIC_HOST', value: 'es-logging.%s.intor.io' % [cluster.global_name] },
                    { name: 'ELASTIC_PORT', value: '9200' },
                    { name: 'LOGLEVEL', value: 'INFO' },
                    { name: 'RETENTION_DAYS', value: '7' },
                  ],
                  image: 'registry.outreach.cloud/curator:0.9.0',
                  name: 'curator',
                  volumeMounts: [
                    { name: 'curator-config', mountPath: '/var/curator/config' },
                    { name: 'curator-action', mountPath: '/var/curator/action' },
                  ],
                },
              ],
              volumes: [
                { name: 'curator-config', configMap: { name: 'curator-config' } },
                { name: 'curator-action', configMap: { name: 'curator-action' } },
              ],
              restartPolicy: 'OnFailure',
            },
          },
        },
      },
      schedule: '1 7 * * *',
    },
  },
  config_file: ok.ConfigMap('curator-config', namespace) {
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
  action_file: ok.ConfigMap('curator-action', namespace){
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
          3:
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
      |||,
    },
  },
};

ok.List() { items_+: all() }
