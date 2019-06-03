local ok = import 'kubernetes/outreach.libsonnet';

ok.Namespace('elasticsearch') {
  metadata+: {
    annotations+: {
      'iam.amazonaws.com/permitted': std.join('|', [
        'thanos',
      ]),
    },
  },
}
