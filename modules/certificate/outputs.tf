output "certificate_pem" {
  value       = acme_certificate.this.certificate_pem
  description = "The certificate in PEM format."
}

output "issuer_pem" {
  value       = acme_certificate.this.issuer_pem
  description = "The intermediate certificate of the issuer."
}

output "private_key_pem" {
  value       = acme_certificate.this.private_key_pem
  description = "The certificate's private key, in PEM format."
}
