local ok = import 'kubernetes/outreach.libsonnet';

local all(
  name = 'elasticsearch-hq',
  namespace = 'elasticsearch-hq',
  host = 'elastichq.outreach.cloud',
) = {
  deployment: ok.Deployment(name, namespace) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers+: [
            ok.Container('oauth2-proxy'){
              image: 'registry.outreach.cloud/oauth2_proxy:2.2.1-alpha.outreach-1.0.7',
              args: [
                '-upstream=http://localhost:5000/',
                '-provider=okta',
                '-cookie-name=_elasticsearch_hq_proxy',
                '-cookie-secure=true',
                '-cookie-expire=168h0m',
                '-cookie-refresh=8h',
                '-cookie-domain=' + host,
                '-http-address=0.0.0.0:8080',
                '-okta-domain=outreach.okta.com',
                '-redirect-url=https://%s/oauth2/callback' % host,
                '-email-domain=outreach.io',
              ],
              envFrom: [
                { secretRef: { name: 'elasticsearch-hq-oauth-proxy'} },
              ],
              ports: [
                { containerPort: 8080, name: 'oauth-proxy' },
              ],
              resources: {
                limits: {
                  memory: '100Mi',
                },
                requests: {
                  cpu: '10m',
                },
              },
            },
            ok.Container(name){
              image: 'elastichq/elasticsearch-hq:release-v3.5.0',
              ports: [
                {
                  containerPort: 5000,
                  name: 'elastichq'
                },
              ],
              resources: {
                limits: {
                  memory: '1Gi',
                },
                requests: {
                  cpu: '100m',
                },
              },
              volumeMounts: [
                { name: 'db', mountPath: '/etc/elastic-hq/data' },
                { name: 'settings', mountPath: '/etc/elastic-hq/settings.json' },
              ],
            },
          ],
          volumes: [
            {
              name: 'db',
              persistentVolumeClaim: { claimName: name },
            },
            {
              name: 'settings',
              configMap: { name: 'elasticsearch-hq-settings' },
            },
          ],
        },
      },
    },
  },
  service: ok.Service(name, namespace) {
    metadata+: { namespace: namespace },
    target_pod: $.deployment.spec.template,
    port: 8080,
  },
  ingress: ok.ContourIngress(
    name,
    namespace,
    tlsSecret = 'elasticsearch-hq-tls',
  ) {
    host:: host,
    spec+: {
      rules: [
        {
          host: host,
          http: {
            paths: [
              {
                backend: {
                  serviceName: name,
                  servicePort: 8080,
                },
              },
            ],
          },
        },
      ],
    },
  },
  settings_configmap: ok.ConfigMap('elasticsearch-hq-settings', namespace) {
    data: {
      'settings.json': |||
        { "SQLALCHEMY_DATABASE_URI" :  "sqlite://etc/elastic-hq/data/elastic-hq.db" }
      |||,
    },
  },
  db_volume: ok.PersistentVolumeClaim(name, namespace) { storage:: '5Gi' },
};

ok.List() { items_+: all() }
