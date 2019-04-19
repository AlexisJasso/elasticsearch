local c = import 'concourse/pipeline.libsonnet';

local github_url = 'https://github.com/getoutreach/elasticsearch/commits';
local name = 'elasticsearch-hq';
local namespace = 'elasticsearch-hq';
local cluster = 'ops.us-west-2';
local source_repo = 'getoutreach/elasticsearch';
local slack = '#deployments';

local pipeline = c.newPipeline(
  name = 'elasticsearch-hq',
  source_repo = 'getoutreach/elasticsearch',
) {
  resource_types_: [],
  resources_: [],
  jobs_: [
    $.newJob(name, 'Master') {
      serial: true,
      steps:: [
        {
          get: 'source',
          trigger: true
        },
        $.slackMessage(
          channel = slack,
          type = 'notice',
          title = ':airplane_departure: Elasticsearch HQ deployment to ops is starting...',
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        ),
        $.k8sDeploy(
          debug = true,
          cluster_name = cluster,
          namespace = namespace,
          manifests = ['kubernetes/elasticsearch-hq.jsonnet'],
          kubecfg_vars = {
            namespace: namespace,
            ts: '$(date +%s)',
          },
          vault_secrets = [
            'deploy/elasticsearch-hq/secrets',
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
          title = ':airplane_arriving: Elasticsearch-hq deployment to ops succeeded! :successkid:',
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        )
      ]),
      on_failure_: $.do([
        $.slackMessage(
          channel = slack,
          type = 'failure',
          title = ":boom: Elasticsearch-hq deployment to ops failed...",
          inputs = [
            $.slackInput(title = 'Deployment', text = name),
          ],
        )
      ]),
    }
  ],
};

[pipeline]
