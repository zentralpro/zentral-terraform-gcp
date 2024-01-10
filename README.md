# Terraform modules for Zentral on GCP

See [example](./example).

## Architecture

![Architecture](./assets/architecture.png)

### VMs

Four different Zentral VMs are used (web, workers, monitoring and ek). The images can be provided by Zentral Pro Services, or they can be built by the customers.

#### Base image

The base image for all instances is the latest official Ubuntu server 22.04 LTS with EBS root volume and HVM virtualization. (see `packer/sources.pkr.hcl` in the `zentral-images` repository).

##### Common configuration
 * Automatic APT updates
 * NTP sync / UTC timezone
 * UFW firewall with deny default policy
 * Postfix server with SMTP relay

##### `ztl_admin`

The `ztl_admin` tool is pre-installed in all the images. It is used during startup to finish configuring the images (`ztl_admin setup`), using the information present in the project metadata, project secrets, and storage buckets. It is also configured as a cron job (`ztl_admin cron`) to run daily tasks (install the TLS certificates on the web instances, cleanup the web sessions, verify the enrollment of the security agents, …).

##### Ops Agent

The [Google Ops Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent) is pre-installed in all the images. It is used to collect telemetry.

##### Vector

The [vector](https://vector.dev/) agent is pre-installed in all the images. It is used to ship some logs to [Google Cloud Logging](https://cloud.google.com/logging?hl=en), and expose some prometheus metrics to the Monitoring instance.

##### Nessus and Xagt

These two optional security agents can be configured by `ztl_admin` at startup. `ztl_admin` can also check daily that these agents are running and properly enrolled, and attempts remediation if necessary.

#### Web instances

A regional Google Compute Instance group is configured to run the web instances. Its capacity can be controlled manually using the Google Compute console or API, or using the `web_mig_target_size` Zentral module terraform variable (recommended).This instance group is used as target pool for the Network Load Balancer (NLB, see below). Health checks are configured to only add an instance to the pool when it is ready (at the end of the ztl_admin setup run).

On the web instances, the Zentral Django application is running, using [gunicorn](https://gunicorn.org/) as the application server (`zentral_web_app.service` systemd service). [Nginx](https://nginx.org/) is used for TLS termination behind the NLB (see Cloud function below for more info), and as a reverse proxy for the gunicorn application server. The static files are served directly by Nginx. Nginx is also used to proxy access to [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) on the Monitoring instance, using the [Nginx auth request module](https://nginx.org/en/docs/http/ngx_http_auth_request_module.html). Requests to Prometheus and Grafana are authorized by making a background request to the Zentral application to verify the identity and the permissions of the user.
Vector is configured to ship the Nginx access and error logs. It also calculates and exports Prometheus metrics based on the Nginx access logs to the Monitoring instance, to be used in Grafana dashboards for example. It is also configured to ship the `zentral_web_app.service` journald logs to Google Cloud Logging.

#### Worker instances

A regional Google Compute Instance group is configured to run the worker instances. Its capacity can be controlled manually using the Google Compute console or API, or using the `worker_mig_target_size` Zentral module terraform variable (recommended).

On the worker instances, the Zentral web app is deployed, and different Zentral workers are configured, each one with its corresponding systemd service:

* `zentral_prepocess_worker`
* `zentral_enrich_worker`
* `zentral_store_worker_*`
* `zentral_process_worker`
* `zentral_celery`

The preprocess, enrich, store and process workers are responsible for running the Zentral event pipeline (see Pub/Sub section below). They also expose Prometheus metrics scraped by the Prometheus server of the Monitoring instance. There are as many store workers as configured event stores. For example, if a Splunk event store is configured, there will be a `zentral_store_worker_splunk.service`). The celery worker is used for the Zentral background tasks (file exports, …).

Vector is configured to ship the journald logs of those services to Google Cloud Logging.

#### Monitoring instance
The monitoring instance is a singleton. It is not managed by an instance group. Prometheus and Grafana are running on this instance. These two services are proxied by Nginx on the web instances.

Prometheus is configured to scrape the Zentral application metrics, the nginx metrics exposed by vector on the web instances, and the Zentral worker metrics on the worker instances.

Grafana is used to build dashboards. It has access to the Google project metrics, and to the Prometheus data. It can also be configured to have access to the event stores.

Two separate block storage devices are used to persist the Grafana and Prometheus data. When a new monitoring instance image is deployed, those volumes are reattached to the new instance during the `ztl_admin setup` run.

#### EK instance

This optional instance can be used to run a single [Elasticsearch](https://www.elastic.co/elasticsearch/) + [Kibana](https://www.elastic.co/kibana/) instance to store the Zentral events.

#### Image preparation and distribution

Images are prepared and distributed by Zentral Pro Services, or they can be built by the customers using another Zentral project (`zentral-images`). Images are referenced in the Zentral Terraform module. Access to the images, and to the `ztl_admin` and `zentral-images` source code (ansible and packer configuration) repositories is given if a subscription or support contract currently exists. The `ztl_admin` and `zentral-images` repositories can be used to build a custom CI/CD pipeline to deploy custom Zentral images.

In order to access the pre-build Zentral images, communicate the list of principals (users, service account) used to run terraform to Zentral Pro Services, and we will grant them access. For more information, see [zentral-images](https://github.com/zentralpro/zentral-images/tree/master/config/gcp) repository.

### Storage

#### CloudSQL

[Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres/quickstart) is used as the main application database for Zentral. [Automatic backups](https://cloud.google.com/sql/docs/postgres/backup-recovery/backups#:~:text=Automated%20backups%20are%20taken%20daily,point%2Din%2Dtime%20recovery.) are configured, with custom data retention. The data stored in the database, the temporary files, and the backups are [encrypted at rest](https://cloud.google.com/docs/security/encryption/default-encryption). The credentials are generated during the Terraform setup and made available to the application via the project metadata (login) and secrets (password).

#### Cloud Storage

Multiple regional buckets are used for this deployment:

 * `ztl-zentral-PROJECT_NAME` is used to store the files generated by the Zentral application (exports, …)
 * `ztl-elastic-PROJECT_NAME` is used to backup the Elasticsearch indices when the EK instance is selected.
 * `ztl-dist-PROJECT_NAME` is an optional regional bucket used to distribute extra software during the VM setup (Crowdstrike debian package, …).

It is also recommended to setup a bucket to use as [terraform backend](https://www.terraform.io/docs/language/settings/backends/gcs.html).

#### Redis

[Memorystore for Redis](https://cloud.google.com/memorystore/docs/redis/redis-overview) is used both as application cache for Zentral, and as queue for the background processing of some long running tasks (exports, …).

### Queues

This Zentral deployment uses [Google Cloud Pub/Sub](https://cloud.google.com/pubsub/docs/overview) to queue and distribute the events. Only the topics are created by the terraform module. The subscriptions are created if they do not already exist by the zentral [`google_pubsub`](https://github.com/zentralopensource/zentral/blob/ff4996091da22bbb1480be27090ab9a9c3c01382/zentral/core/queues/backends/google_pubsub.py) queue backend. Multiple workers can share the same topic subscription to increase the throughput.

There is also an optional topic to schedule the certbot cloud function.

#### `ztl-raw-event-topic`

Some events generated outside of Zentral need some extra processing (call to an external API for example), and are send to this topic first. A [`preprocess worker`](https://github.com/zentralopensource/zentral/blob/ff4996091da22bbb1480be27090ab9a9c3c01382/zentral/core/queues/backends/google_pubsub.py#L43) will read the events from a `raw-events-subscription` attached to this topic, build zentral events, and post them to the `ztl-events-topic`.

#### `ztl-events-topic`

This is the topic receiving all the Zentral events, either directly or preprocessed from the `ztl-raw-event-topic`. An [`enrich worker`](https://github.com/zentralopensource/zentral/blob/ff4996091da22bbb1480be27090ab9a9c3c01382/zentral/core/queues/backends/google_pubsub.py#L117) will read the events from a `events-subscription` attached to this topic, add extra information (inventory, severity, …) and post them to the `ztl-enriched-events-topic`.

#### `ztl-enriched-events-topic`

All Zentral events are posted to this topic, with the extra information they received during the enrichment step above. Multiple subscriptions are attached to this topic:

 * `*-store-enriched-events-subscription` for each of the configured event stores (`*` is replaced by the name of the store in the Zentral configuration). A corresponding [`store worker *`](https://github.com/zentralopensource/zentral/blob/ff4996091da22bbb1480be27090ab9a9c3c01382/zentral/core/queues/backends/google_pubsub.py#L224) will read one or many of the enriched events, and try to store them.

 * `process-enriched-events-subscription` where the events are queued for the [`process worker`](https://github.com/zentralopensource/zentral/blob/ff4996091da22bbb1480be27090ab9a9c3c01382/zentral/core/queues/backends/google_pubsub.py#L178). This worker is used to trigger the probe actions on the matching events.

#### `ztl-certbot`

Used by the [google cloud scheduler](https://cloud.google.com/scheduler/docs/quickstart) to trigger the certbot cloud function. Only created if the certbot cloud function is activated.

### Networking

#### General overview

A custom VPC is used with two subnets on 2 different zones. Firewall rules are configured to filter the connections to the different instances based on their network tags. We benefit from the [default authentication and encryption](https://cloud.google.com/docs/security/encryption-in-transit#virtual_machine_to_virtual_machine) of communication between VMs on a GCP VPC.

The instances do not have public IP addresses. A NAT router is used to give them access to the Internet. The IP addresses used by this router can optionaly be managed by Terraform. If not, they are automatically managed by GCP. These addresses are the ones used for example by the Splunk store worker to connect to the Splunk HEC.

A network load balancer is used to balance the traffic coming from the end users and the endpoints to the Zentral web instances, so that Nginx could be configured to verify the client certificates (mTLS). The [custom headers](https://cloud.google.com/load-balancing/docs/https/custom-headers#mtls-variables) that the managed Google mTLS application load balancer can provide might be enough to authenticate Santa, but not to authenticate the MDM daemon and agent at the moment (last checked: 2023-11-02, #TODO).

The TLS certificates and the key can be loaded by Terraform from local files or environment variables, or generated by a cloud function. In both cases, the certificate and the chain are stored in the project metadata. The key is stored as a google secret. Once per day, the `ztl_admin cron` command will fetch the certificate, the chain, and the key, and update the local configurations (Nginx and Zentral) on the web instances. The cloud function is a python runtime that uses the certbot module to request Let's Encrypt certificates using the ACME protocol, with the [DNS challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge). Google Cloud DNS and Cloudflare are supported by the cloud function. Credentials with permissions to edit the DNS zone need to be provided for Cloudflare.

Options are available in the zentral terraform module to forward the origin IP address if Cloudflare is used as proxy.

#### Connections

##### Web instances

**[OUTBOUND]** Google cloud - Cloud SQL

mTLS authentication using the [Cloud SQL auth proxy](https://cloud.google.com/sql/docs/postgres/connect-auth-proxy), and instance IAM authentication. The Zentral application communicates locally with the proxy.

**[OUTBOUND]** Google cloud - Memory Store

Using a [private service access](https://cloud.google.com/memorystore/docs/redis/networking#private_services_access) to authorize only our VPC to communicate with the Redis instance.

**[OUTBOUND]** Google cloud - Project metadata, secrets, logging, buckets, Pub/Sub

API calls using HTTPS (443) endpoints, and instance IAM authentication.

**[OUTBOUND]** **[OPTIONAL]** Zentral EK instance

API calls in the VPC, HTTP (9200) endpoints.

**[OUTBOUND]** **[OPTIONAL]** third party - Splunk

Splunk API endpoint authenticated using an API token and optional extra headers, over HTTPS.

**[OUTBOUND]** Official Ubuntu repositories

To receive the OS updates, HTTPS (443)

**[OUTBOUND]** GitHub

To get the latest version of the agents, HTTPS (443).

**[INBOUND]** Google cloud - Managed instance group

HTTP (8081) health check on the `/instance-health-check` Nginx endpoint

**[INBOUND]** Google cloud - Network load balancer

HTTP (8080) health check on the `/app-health-check` Nginx endpoint, no authentication, port and ip source range limited using the VPC firewall.

HTTP (80) and HTTPS (443) connections from the internet, via the NLB, to Nginx.

**[INBOUND]** Zentral monitoring instance - Prometheus

HTTP (9920) vector `/metrics` scraping by Prometheus using the internal VPC. No authentication, port and source network tag (`monitoring`) limited using the VPC firewall.

##### Worker instances

**[OUTBOUND]** Google cloud - Cloud SQL

mTLS authentication using the [Cloud SQL auth proxy](https://cloud.google.com/sql/docs/postgres/connect-auth-proxy), and instance IAM authentication. The Zentral application communicates locally with the proxy.

**[OUTBOUND]** Google cloud - Memory Store

Using a [private service access](https://cloud.google.com/memorystore/docs/redis/networking#private_services_access) to authorize only our VPC to communicate with the Redis instance.

**[OUTBOUND]** Google cloud - Project metadata, secrets, logging, buckets, Pub/Sub

API calls using HTTPS (443) endpoints, and instance IAM authentication.

**[OUTBOUND]** **[OPTIONAL]** Zentral EK instance

API calls in the VPC, HTTP (9200) endpoints.

**[OUTBOUND]** **[OPTIONAL]** third party - Splunk

Splunk API endpoint authenticated using an API token and optional extra headers, over HTTPS.

**[OUTBOUND]** Official Ubuntu repositories

To receive the OS updates, HTTPS (443)

**[INBOUND]** Google cloud - Managed instance group

HTTP (9910) health check on the `/metrics` vector endpoint.


**[INBOUND]** Zentral monitoring instance - Prometheus

HTTP (9910) vector `/metrics` scraping by Prometheus using the internal VPC. No authentication, port and source network tag (`monitoring`) limited using the VPC firewall.

##### Monitoring instance

**[OUTBOUND]** Google cloud - Project metadata, secrets, logging, buckets, Pub/Sub

API calls using HTTPS (443) endpoints, and instance IAM authentication.

**[OUTBOUND]** **[OPTIONAL]** Zentral EK instance

API calls in the VPC, HTTP (9200) endpoints.

**[OUTBOUND]** **[OPTIONAL]** third party - Splunk

Splunk API endpoint authenticated using an API token and optional extra headers, over HTTPS.

**[OUTBOUND]** Official Ubuntu repositories

To receive the OS updates, HTTPS (443)

##### EK instance

**[OUTBOUND]** Google cloud - Project metadata, secrets, logging, buckets, Pub/Sub

API calls using HTTPS (443) endpoints, and instance IAM authentication.

**[OUTBOUND]** Official Ubuntu repositories

To receive the OS updates, HTTPS (443)

**[INBOUND]** **[OPTIONAL]** Zentral web & worker instances

API calls in the VPC, HTTP (9200) endpoints. No authentication, port and source network tag (`web`, `worker`) limited using the VPC firewall.

## Data lifecycle

### Collection

Agents running on the macOS clients are collecting the information and sending it via API calls to Zentral. Inventory information can also come from third party inventory systems like Jamf. Events are normalized, and metadata about the source is added (IP address, Geo Localization, User agent).

#### Agents

##### Osquery

[Osquery](https://osquery.io/) uses basic SQL commands to leverage a relational data-model to describe a device. Osquery is a multi-platform tool. [Tables](https://osquery.io/schema/5.10.2/) exist for most of OS resources. The query results are pushed to Zentral using HTTPS API calls. The configuration for Osquery is downloaded from Zentral using HTTPS API calls. All API calls are logged using the Zentral event pipeline.

##### Santa

[Santa](https://santa.dev/) is a binary and file access authorization system for macOS. It consists of a system extension that allows or denies attempted executions using a set of rules stored in a local database. Decision events (Decision, Machine serial number, `PID`, `PPID`, `UID`, `GID`, path, arguments, code signature) are sent to Zentral using HTTPS API calls. Rule updates are downloaded from Zentral using HTTPS API calls. All API calls are logged using the Zentral event pipeline.

### Processing

Events are first processed by the Zentral `web` VMs. Updates to the status of the machines are written in the CloudSQL database. Events are then written to the Google Cloud Pub/Sub queues, and processed by the `worker` VMs. Events in Google Cloud Pub/Sub are [encrypted at rest and in transit](https://cloud.google.com/pubsub/docs/encryption).

### Storage

#### Configuration

The configuration data for Zentral itself and the agents or third party inventory is stored in the Cloud SQL database. Audit events are generated when configuration objects are created, modified and deleted, with the unified metadata (User information, IP, authentication) and the previous state if relevant.

#### Hardware and software inventory

The inventory data (software, hardware) is stored in the Cloud SQL database. Change events are generated too.

#### Events

The events are shipped to the configured event stores, by the store processes on the `worker` VMs. If the EK instance is configured to store the events in this deployment, indices lifecycles and backups are managed using the Terraform variables. Data in the EK instance is encrypted at rest, and the backups are stored in the backup bucket, also encrypted at rest. Data retention, encryption and backup in third party stores (Splunk for example) is out-of-scope for this document.

## Deployment

### Manual tasks!!!

Sadly, to enable some APIs on the project, APIs are required! Make sure the *Service Usage API* and *Cloud Resource Manager API* are enabled on the project before attempting a deployment.

### Permissions / Roles

#### In the GCP project

GCP predefined roles covering the necessary permissions to run the TF setup:

|TF Resources|Description|GCP Predefined roles|Ref.|
|---|---|---|---|
|`google_project_service`|To enable the required APIs|`roles/serviceusage.serviceUsageAdmin`|[access](https://cloud.google.com/service-usage/docs/access-control#roles)|
|`google_project_iam_binding`<br>`google_project_iam_custom_role`<br>`google_project_iam_member`<br>`google_service_account`|To manage the custom service accounts and policies|`roles/iam.roleAdmin`<br>`roles/iam.serviceAccountAdmin`<br>`roles/iam.serviceAccountUser`<br>`roles/resourcemanager.projectIamAdmin`| |
|`google_compute_address`<br>`google_compute_subnetwork`<br>`google_compute_disk`<br>`google_compute_firewall`<br>`google_compute_forwarding_rule`<br>`google_compute_global_address`<br>`google_compute_http_health_check`<br>`google_compute_instance`<br>`google_compute_instance_template`<br>`google_compute_network`<br>`google_compute_project_metadata_item`<br>`google_compute_region_instance_group_manager`<br>`google_compute_router`<br>`google_compute_router_nat`<br>`google_compute_target_pool`| |`roles/compute.admin`|[roles](https://cloud.google.com/compute/docs/access/iam#predefinedroles)|
|`google_service_networking_connection`|Private networking peering|`roles/servicenetworking.networksAdmin`| |
|`google_pubsub_topic`| |`roles/pubsub.admin`|[access](https://cloud.google.com/pubsub/docs/access-control)|
|`google_redis_instance`| |`roles/redis.admin`|[access](https://cloud.google.com/memorystore/docs/redis/access-control)|
|`google_secret_manager_secret`<br>`google_secret_manager_secret_iam_member`<br>`google_secret_manager_secret_version`| |`roles/secretmanager.admin`|[access](https://cloud.google.com/secret-manager/docs/access-control)|
|`google_sql_database`<br>`google_sql_database_instance`<br>`google_sql_user`| |`roles/cloudsql.admin`|[access](https://cloud.google.com/sql/docs/postgres/project-access-control)|
|`google_storage_bucket`<br>`google_storage_bucket_iam_member`<br>and the TF state backend| |`roles/storage.admin`|[roles](https://cloud.google.com/storage/docs/access-control/iam-roles)|
|`google_kms_key_ring`<br>`google_kms_crypto_key`|To manage the KMS crypto key for the Zentral secret engine.|`roles/cloudkms.admin`|[roles](https://cloud.google.com/kms/docs/reference/permissions-and-roles#cloudkms.admin)|
|**ONLY IF ELASTICSEARCH INSTANCE:**||||
|`google_service_account_key`|To manage the SA key for the ES backups|`roles/iam.serviceAccountKeyAdmin`|[access](https://cloud.google.com/iam/docs/understanding-roles#iam.serviceAccountKeyAdmin)|
|**ONLY IF CLOUD FUNCTION:**||||
|`google_app_engine_application`| |`roles/appengine.appAdmin`<br>`roles/appengine.appCreator`|[access](https://cloud.google.com/appengine/docs/standard/go/roles#predefined_roles)|
|`google_cloud_scheduler_job`| |`roles/cloudScheduler.admin`| |
|`google_cloudfunctions_function`| |`roles/cloudfunctions.developer`<br>*(IAM permissions already covered)*|[roles](https://cloud.google.com/functions/docs/reference/iam/roles)|
|**ONLY IF MONITORING:**||||
|`google_monitoring_alert_policy`| |`roles/monitoring.alertPolicyEditor`| |
|`google_monitoring_notification_channel`| |`roles/monitoring.notificationChannelEditor`| |
|`google_monitoring_uptime_check_config`| |`roles/monitoring.uptimeCheckConfigEditor`| |
