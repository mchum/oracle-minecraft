terraform {
    # S3 backend is broken due to generated secret keys containing special characters
    # https://qiita.com/rakys/items/d918899e34802cd681d3
    # backend "s3" {}
    required_version = ">= 1.3.6"
    required_providers {
        oci = {
            source = "oracle/oci"
        }
    }
}

provider "oci" {
    tenancy_ocid        = var.tenancy_ocid
    user_ocid           = var.user_ocid
    private_key_path    = var.private_key_path
    fingerprint         = var.fingerprint
    region              = var.region
}

# Networking
module "vcn" {
    source  = "oracle-terraform-modules/vcn/oci"

    # Required
    compartment_id                  = var.compartment_ocid
    region                          = var.region
    vcn_name                        = "minecraft"

    # Optional
    # By default, free tier service limit for NAT Gateway is 0
    lockdown_default_seclist        = false
    create_internet_gateway         = true
    create_nat_gateway              = false
    enable_ipv6                     = true
    vcn_cidrs                       = ["10.0.0.0/16"]
}

resource "oci_core_route_table" "default" {
    compartment_id = var.compartment_ocid
    vcn_id = module.vcn.vcn_id
    display_name = "Default"
    route_rules {
        network_entity_id = module.vcn.internet_gateway_id
        description = "Allow access from all IPs"
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_security_list" "public" {
    # Required
    compartment_id = var.compartment_ocid
    vcn_id = module.vcn.vcn_id
    display_name = "Security List for public Subnet"
    egress_security_rules {
        protocol            = "all"
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
    }
    ingress_security_rules {
        protocol    = "1"
        source      = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        description = "ICMP traffic"
        icmp_options {
            type = 3
            code = 4
        }
    }
    ingress_security_rules {
        protocol    = "6"
        source      = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        description = "TCP traffic to port 22"
        tcp_options {
            // These values correspond to the destination port range
            min = 22
            max = 22
        }
    }
    ingress_security_rules {
        protocol    = "6"
        source      = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        description = "TCP traffic for Minecraft"
        tcp_options {
            // These values correspond to the destination port range
            min = 25565
            max = 25565
        }
    }
    ingress_security_rules {
        protocol    = "17"
        source      = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        description = "UDP traffic for Minecraft"
        udp_options {
            // These values correspond to the destination port range
            min = 25565
            max = 25565
        }
    }
}

resource "oci_core_subnet" "public" {
    cidr_block                  = "10.0.0.0/24"
    compartment_id              = var.compartment_ocid
    vcn_id                      = module.vcn.vcn_id
    display_name                = "public"
    prohibit_internet_ingress   = false
    prohibit_public_ip_on_vnic  = false
    route_table_id              = oci_core_route_table.default.id
    security_list_ids           = [oci_core_security_list.public.id]
}

data "oci_identity_availability_domain" "availability_domain" {
    compartment_id = var.tenancy_ocid
    ad_number = "1"
}

# Compute
# Free Tier: 
# * 4 ARM-based A1 cores and 24 GB memory
# * 200 GB block storage, minimum 50 GB used here
resource "oci_core_instance" "instance" {
    # Required
    availability_domain = data.oci_identity_availability_domain.availability_domain.name
    compartment_id = var.compartment_ocid
    shape = "VM.Standard.A1.Flex"
    source_details {
        source_id = var.image_source_ocid
        source_type = "image"
        boot_volume_size_in_gbs = 50
    }

    # Optional
    display_name = "instance"
    shape_config {
        ocpus = 4
        memory_in_gbs = 24
    }
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.public.id
    }
    preserve_boot_volume = false
    metadata = {
        ssh_authorized_keys = file(var.ssh_public_keypath)
    }
}

output "worker_node_ip" {
    description = "IP of worker node"
    value = oci_core_instance.instance.public_ip
}