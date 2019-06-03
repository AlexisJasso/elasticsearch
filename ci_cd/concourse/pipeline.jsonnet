local c = import 'concourse/pipeline.libsonnet';

local name = 'elasticsearch';
local namespace = 'elasticsearch';
local source_repo = 'getoutreach/elasticsearch';
local slack = '#deployments';
local clusters = [
  {
    name: 'ops.us-west-2',
    passed: null
  },
  {
    name: 'staging.us-east-2',
    passed: ['ops.us-west-2'],
  },
  {
    name: 'staging.us-west-2',
    passed: ['staging.us-east-2'],
  },
  {
    name: 'production.us-east-1',
    passed: ['staging.us-west-2'],
  },
  {
    name: 'production.us-west-2',
    passed: ['production.us-east-1'],
  },
];

local pipeline = c.newPipeline(
  name        = name,
  source_repo = 'getoutreach/elasticsearch',
);

# Deploy elasticsearch manifests
local elasticsearch_jobs = [
  pipeline.newJob(cluster.name, 'Master Branch') {
    serial: true,
    steps:: [
      {
        get: 'source',
        trigger: true,
        [if std.type(cluster.passed) != "null" then "passed"]: cluster.passed,
      },
      pipeline.slackMessage(
        channel = slack,
        type = 'notice',
        title = ':airplane_departure: Elasticsearch deployment to %s is starting...' % [cluster.name],
      ),
      pipeline.k8sDeploy(
        debug = true,
        cluster_name = cluster.name,
        namespace = namespace,
        manifests = ['ci_cd/kubernetes/*.jsonnet'],
        kubecfg_vars = {
          namespace: namespace,
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
        channel = slack,
        type = 'success',
        title = ':airplane_arriving: Elasticsearch deployment to %s succeeded! :successkid:' % [cluster.name],
      )
    ]),
    on_failure_: pipeline.do([
      pipeline.slackMessage(
        channel = slack,
        type = 'failure',
        title = ":boom: Elasticsearch deployment to %s failed..." % [cluster.name],
      )
    ]),
  }
  for cluster in clusters
];

[
  pipeline {
    jobs_: elasticsearch_jobs,
  },
]
