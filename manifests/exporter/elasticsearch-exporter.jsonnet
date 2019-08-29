local ok = import 'kubernetes/outreach.libsonnet';
local exporter = import '../libs/exporter.libsonnet';

local exporters = {
  flagship_prod: exporter.newExporter("flagship-prod", "http://es-flagship.ss-uw2-pd.intor.io:80"),
  flagship_staging: exporter.newExporter("flagship-staging", "http://es-flagship.ss-uw1-stg.intor.io:80" ),
  potpourri_prod: exporter.newExporter("potpourri-prod", "http://es-potpourri.ss-uw2-pd.intor.io:80"),
  potpourri_staging: exporter.newExporter("potpourri-staging", "http://es-potpourri.ss-uw1-stg.intor.io:80"),
  kube_prod: exporter.newExporter("kube-prod", "http://es-kube.ss-uw2-pd.intor.io:80"),
  kube_staging: exporter.newExporter("kube-staging", "http://es-kube.ss-uw1-stg.intor.io:80"),
  ingestitron_prod: exporter.newExporter("ingestitron-prod", "http://es-ingestitron.data1.intor.io:80"),
  ingestitron_staging: exporter.newExporter("ingestitron-staging", "http://es-ingestitron.stagingdata1.intor.io"),
};


ok.List() {
  items+: std.flattenArrays([ok.objectValues(o) for o in ok.objectValues(exporters)])
}