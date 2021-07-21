# Zentral terraform deployment example

 * The [`vpc`](../../modules/vpc) and [`zentral`](../../modules/zentral) modules are cloned from this repository.
 * A SSH key [needs to be configured](https://www.terraform.io/docs/cloud/workspaces/ssh-keys.html) in Terraform Enterprise/Cloud to clone them.


## mTLS setup

To activate the mTLS setup, you need to set `fqdn_mtls` and `tls_cachain` in the zentral module.

**IMPORTANT** This new parameters will only be used for new zentral web instances. They will not be used by existing web instances. To activate this, you need to refresh the web instances in the web managed instance group, either in the google cloud console or using `gcloud`. But if you deploy these new parameters alongside new images, they will be picked up automatically.

### fqdn_mtls

This is a second subdomain that will be configured in nginx with required client certificate for authentication. If you have `zentral.example.com` for `fqdn`, you could use for example `zentral-mtls.example.com`, but any other domain would work. You also need to make sure that this domain points to the IP address of the load balancer (same IP address as `fqdn`).

### tls_cachain

This parameter is used to pass the chain of certificates used by Nginx to verify the client certificates.

The zentral module in this example `main.tf` is configured to load the chain from `cfg/cachain.pem` if it exists.

You can build this file by concatenating all the certificates in the chain, from the intermediary used to sign the client certificates to the root certificate – including the root certificate – in PEM form.

This file will be used during the provisioning of the zentral web instances for the [`ssl_client_certificate`](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_client_certificate) directive in the Nginx server block used for `fqdn_mtls`.

`ssl_client_certificate` is preferred over [`ssl_trusted_certificate`](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_trusted_certificate), because agents like Google Santa will automatically use KeyChain **device** certificates issued by the intermediaries whose X509 Names are sent via the TLS protocol by Nginx. In that case, no need to add extra agent configuration.

**IMPORTANT** Remember to update this chain, and add the new intermediaries, when the CA used to signed the client certificate is updated.
