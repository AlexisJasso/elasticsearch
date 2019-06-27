local c = import 'concourse/pipeline.libsonnet';
local es_clusters = import '../../es-clusters.libsonnet';

local pipeline = c.newPipeline(
  name        = 'elasticsearch',
  source_repo = 'getoutreach/elasticsearch',
);

# Deploy elasticsearch manifests
local name                = 'elasticsearch';
local slack_channel       = '#deployments';
local elasticsearch_jobs  = [
  pipeline.newJob('%s-%s-to-%s' % [es.elasticsearch.name, name, es.cluster], '1. Elasticsearch') {
    local es_name = '%s-%s' % [es.elasticsearch.name, name],
    serial: true,
    steps:: [
      {
        get: 'source',
        trigger: true,
        [if std.type(es.passed) != "null" then "passed"]: es.passed,
      },
      pipeline.slackMessage(
        channel = slack_channel,
        type = 'notice',
        title = ':airplane_departure: %s deployment to %s is starting...' % [es_name, es.cluster],
      ),
      pipeline.k8sDeploy(
        debug = true,
        cluster_name = es.cluster,
        namespace = es.namespace,
        manifests = [
          'manifests/elasticsearch/*.jsonnet',
          'manifests/curator/*.jsonnet',
          'manifests/kibana/*.jsonnet',
        ],
        kubecfg_vars = {
          ts: '$(date +%s)',
        },
        vault_secrets = [
          'deploy/monitoring/kibana/secrets',
        ],
        params = {
          validation_retries: "100",
        },
      ),
    ],
    plan_: pipeline.steps(self.steps),
    on_success_: pipeline.do([
      pipeline.slackMessage(
        channel = slack_channel,
        type = 'success',
        title = ':airplane_arriving: %s deployment to %s succeeded! :successkid:' % [es_name, es.cluster],
      )
    ]),
    on_failure_: pipeline.do([
      pipeline.slackMessage(
        channel = slack_channel,
        type = 'failure',
        title = ":boom: %s deployment to %s failed..." % [es_name, es.cluster],
      )
    ]),
  }
  for es in es_clusters
];

[
  pipeline {
    jobs_: elasticsearch_jobs,
  },
]
