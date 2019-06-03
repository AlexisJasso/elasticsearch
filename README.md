# ElasticSearch on Kubernetes at Outreach

## Deployed Services

- Prometheus exporter for monitoring elasticsearch clusters
- Elasticsearch HQ - A dashboard for Elasticsearch clusters located at http://elastichq.outreach.cloud
- The elasticsearch-logging cluster in each kubernetes cluster
- The curator jobs operating on the above cluster
- A kibana instance pointed at the above cluster

## Update Pipeline

```bash
outreach concourse update -p elasticsearch ci_cd/concourse/pipeline.jsonnet
```
