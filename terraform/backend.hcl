bucket   = "minecraft"
key      = "terraform-states/minecraft.tfstate"
region   = "ca-toronto-1"
endpoint = "https://{{ REPLACEME }}.compat.objectstorage.ca-toronto-1.oraclecloud.com"
shared_credentials_file = "./states_bucket_credentials"

skip_region_validation      = true
skip_credentials_validation = true
skip_metadata_api_check     = true
force_path_style            = true
