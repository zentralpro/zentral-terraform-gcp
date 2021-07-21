# Configuration files

Place the following files in this folder, before launching terraform:

 * **REQUIRED** `base.json` the Zentral configuration skeleton
 * **OPTIONAL** `cachain.pem` the chain of certificates used to validate the client certificates. Only needed with `fqdn_mtls` to activate the mTLS endpoint. Must be a complete chain ending with the root CA certificate (self-signed).
