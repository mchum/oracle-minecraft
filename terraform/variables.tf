variable "compartment_ocid" {
  type = string
  description = "comparment to deploy to"
}

variable "ssh_public_keypath" {
  type = string
  description = "Path to RSA public key, OCI has issue with ed25519"
}