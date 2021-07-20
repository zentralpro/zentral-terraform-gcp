# Terraform modules for Zentral on GCP

See [example](./example).

## Permissions / Roles

GCP predefined roles covering the necessary permissions to run the TF setup:

|TF Resources|Description|GCP Predefined roles|Ref.|
|---|---|---|---|
|`google_project_service`|To enable the required APIs|`roles/serviceusage.serviceUsageAdmin`|[access](https://cloud.google.com/service-usage/docs/access-control#roles)|
|`google_project_iam_binding`<br>`google_project_iam_custom_role`<br>`google_project_iam_member`<br>`google_service_account`<br>`google_service_account_key`|To manage the custom service accounts and policies|`roles/iam.roleAdmin`<br>`roles/iam.serviceAccountAdmin`<br>`roles/iam.serviceAccountUser`<br>`roles/iam.serviceAccountKeyAdmin`<br>`roles/iam.securityAdmin`||
|`google_compute_address`<br>`google_compute_subnetwork`<br>`google_compute_disk`<br>`google_compute_firewall`<br>`google_compute_forwarding_rule`<br>`google_compute_global_address`<br>`google_compute_http_health_check`<br>`google_compute_instance`<br>`google_compute_instance_template`<br>`google_compute_network`<br>`google_compute_project_metadata_item`<br>`google_compute_region_instance_group_manager`<br>`google_compute_router`<br>`google_compute_router_nat`<br>`google_compute_target_pool`||`roles/compute.admin`|[roles](https://cloud.google.com/compute/docs/access/iam#predefinedroles)|
|`google_service_networking_connection`|Private networking peering|`roles/servicenetworking.networksAdmin`||
|`google_pubsub_topic`||`roles/pubsub.admin`|[access](https://cloud.google.com/pubsub/docs/access-control)|
|`google_redis_instance`||`roles/redis.admin`|[access](https://cloud.google.com/memorystore/docs/redis/access-control)|
|`google_secret_manager_secret`<br>`google_secret_manager_secret_iam_member`<br>`google_secret_manager_secret_version`||`roles/secretmanager.admin`|[access](https://cloud.google.com/secret-manager/docs/access-control)|
|`google_sql_database`<br>`google_sql_database_instance`<br>`google_sql_user`||`roles/cloudsql.admin`|[access](https://cloud.google.com/sql/docs/postgres/project-access-control)|
|`google_storage_bucket`<br>`google_storage_bucket_iam_member`<br>and the TF state backend||`roles/storage.admin`|[roles](https://cloud.google.com/storage/docs/access-control/iam-roles)|
|**ONLY IF CLOUD FUNCTION:**||||
|`google_app_engine_application`||`roles/appengine.appAdmin`<br>`roles/appengine.appCreator`|[access](https://cloud.google.com/appengine/docs/standard/go/roles#predefined_roles)|
|`google_cloud_scheduler_job`||`roles/cloudScheduler.admin`||
|`google_cloudfunctions_function`||`roles/cloudfunctions.developer`<br>*(IAM permissions already covered)*|[roles](https://cloud.google.com/functions/docs/reference/iam/roles)|


