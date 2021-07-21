# Zentral terraform project setup example

 * The [`project`](../../modules/project) module is cloned from this repository.
 * A SSH key [needs to be configured](https://www.terraform.io/docs/cloud/workspaces/ssh-keys.html) in Terraform Enterprise/Cloud to clone them.

This example uses the [`project`](../../modules/project) module to setup a GCP project for the Zentral terraform deployment. This will create a service account with the recommended permissions, and a bucket to store the terraform state. It can be used in combination with the [deployment example](../zentral).
