local c = import 'concourse/pipeline.libsonnet';

local github_url = 'https://github.com/getoutreach/elasticsearch/commits';
local name = 'es-monitoring';
local namespace = 'monitoring';
local source_repo = 'getoutreach/elasticsearch';
local slack = '#deployments';
local job_params = [
  {
    name: 'Ops',
    cluster: 'ops.us-west-2',
    passed: null
  },
  {
    name: 'Staging East',
    cluster: 'staging.us-east-2',
    passed: ['Ops'],
  },
  {
    name: 'Staging West',
    cluster: 'staging.us-west-2',
    passed: ['Staging East'],
  },
  {
    name: 'Production East',
    cluster: 'production.us-east-1',
    passed: ['Staging West'],
  },
  {
    name: 'Production West',
    cluster: 'production.us-west-2',
    passed: ['Production East'],
  },
];

local pipeline = c.newPipeline(
  name = 'es-monitoring',
  source_repo = 'getoutreach/elasticsearch',
) {
  resource_types_: [],
  resources_: [],
  jobs_: [
    $.newJob(params.name, 'Master') {
      serial: true,
      steps:: [
        {
          get: 'source',
          trigger: true,
          [if std.type(params.passed) != "null" then "passed"]: params.passed,
        },
        $.slackMessage(
          channel = slack,
          type = 'notice',
          title = ':airplane_departure: Elasticsearch monitoring deployment to %s is starting...' % [params.cluster],
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        ),
        $.k8sDeploy(
          debug = true,
          cluster_name = params.cluster,
          namespace = namespace,
          manifests = ['kubernetes/monitoring/*.jsonnet', 'kubernetes/monitoring/*.yaml'],
          kubecfg_vars = {
            namespace: namespace,
            ts: '$(date +%s)',
          },
          vault_secrets = [
            'monitoring/kibana/secrets',
          ],
          params = {
            validation_retries: "100",
          },
        ),
      ],
      plan_: $.steps(self.steps),
      on_success_: $.do([
        $.slackMessage(
          channel = slack,
          type = 'success',
          title = ':airplane_arriving: Elasticsearch monitoring deployment to %s succeeded! :successkid:' % [params.cluster],
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        )
      ]),
      on_failure_: $.do([
        $.slackMessage(
          channel = slack,
          type = 'failure',
          title = ":boom: Elasticsearch monitoring deployment to %s failed..." % [params.cluster],
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        )
      ]),
    }
    for params in job_params
  ],
};

[pipeline]
