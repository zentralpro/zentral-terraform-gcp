# GCP cluster setup

A brief summary of what each GCP component is used for

## Network Load Balancer

- forward traffic to ZTL web instances

## ZTL Web instance

- Nginx
- Django web app
- Gunicorn
- HTTP traffic from endpoints
- TLS validation (mTLS)
- User interface and API
- Provide signed URLs, access items from CloudStorage

## ZTL Worker instance

- Events processing pipeline
- Background task processing (tasks for export, build .pkg)
- Writes to Cloud Storage

## ElasticSearch / Kibana (ek instance)

- ElasticSearch
- Kibana
- Default/primary DataStore

## ZTL Monitoring instance

- Prometheus
- Grafana
- Monitoring Metrics

## CloudSQL

- PostgreSQL DB
- Store rules, inventory data

## Cloud MemoryStore

- Redis cache

## Cloud Pub/Sub

- Processing queue for raw_events, events, enriched_events

## Cloud Storage

- Bucket for the zentral app Django file storage
- Bucket for the ElasticSearch backups
- Bucket for the distribution of extra software

## Cloud Function

- Scheduled certbot cloud function
- get and set the project metadata for certificate, key
- can work with cloudflare DNS

## Stackdriver

- Collect log files from instances

## ZTL admin tool

- Configure instances in a cloud deployment
- auto discovery, metadata, secrets

## Secondary Data Store

- data shipping to Splunk HEC, DataDog
