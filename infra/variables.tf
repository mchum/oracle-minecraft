variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "region" {
  type = string
  default = "ca-toronto-1"
}

variable "compartment_ocid" {
  type = string
  description = "comparment to deploy to"
}

variable "image_source_ocid" {
  type = string 
  description = "Image OCID, use an `aarch` image"
}

variable "ssh_public_keypath" {
  type = string
  description = "Path to RSA public key, OCI has issue with ed25519"
}

variable "bootstrap_script_filepath" {
  type = string
  description = "Path to bootstrap script"
  default = "bootstrap/startup.sh"
}