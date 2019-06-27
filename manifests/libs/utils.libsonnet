local cluster = import 'kubernetes/cluster.libsonnet';

{
  GetCluster(name, clusters):
    std.filter(function(x) if x.name == name && x.cluster == cluster.global_name then true else false, clusters)[0],
}
