provider "azurerm" {
  use_oidc = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment"      = var.environment
    "Parent Business"  = "Children’s Care"
    "Portfolio"        = "Newly Onboarded"
    "Product"          = "EY Recovery"
    "Service"          = "Newly Onboarded"
    "Service Line"     = "Newly Onboarded"
    "Service Offering" = "EY Recovery"
  }
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_name_prefix}-rg"
  location = var.azure_region

  tags = merge(local.common_tags, {
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Network resources
module "network" {
  source = "./terraform-azure-network"

  location             = var.azure_region
  resource_group       = azurerm_resource_group.rg.name
  resource_name_prefix = var.resource_name_prefix
}

# Create Database resources
module "database" {
  source = "./terraform-azure-database"

  location                    = var.azure_region
  resource_group              = azurerm_resource_group.rg.name
  resource_name_prefix        = var.resource_name_prefix
  psqlfs_subnet_id            = module.network.psqlfs_subnet_id
  psqlfs_dns_zone_id          = module.network.psqlfs_dns_zone_id
  psqlfs_sku                  = var.psqlfs_sku
  psqlfs_storage              = var.psqlfs_storage
  psqlfs_username             = var.psqlfs_username
  psqlfs_password             = var.psqlfs_password
  psqlfs_geo_redundant_backup = var.psqlfs_geo_redundant_backup
  depends_on                  = [module.network]
}

# Create Web Application resources
module "webapp" {
  source = "./terraform-azure-web"

  asp_sku              = var.asp_sku
  location             = var.azure_region
  resource_group       = azurerm_resource_group.rg.name
  resource_name_prefix = var.resource_name_prefix
  webapp_subnet_id     = module.network.webapp_subnet_id
  webapp_name          = "eyrecovery-dev"
  webapp_app_settings = {
    "DATABASE_URL"                        = var.webapp_database_url
    "DOCKER_REGISTRY_SERVER_URL"          = var.webapp_docker_registry_url
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.webapp_docker_registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.webapp_docker_registry_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "GOVUK_APP_DOMAIN"                    = "london.cloudapps.digital" #TODO: Remove this dependency post-migration to Azure
    "GOVUK_WEBSITE_ROOT"                  = "ey-recovery-dev"          #TODO: Remove this dependency post-migration to Azure
    "BOT_TOKEN"                           = var.webapp_config_bot_token
    "CONTENTFUL_ENVIRONMENT"              = var.webapp_config_contentful_environment
    "CONTENTFUL_PREVIEW"                  = var.webapp_config_contentful_preview
    "DOMAIN"                              = var.webapp_config_domain
    "EDITOR"                              = var.webapp_config_editor
    "FEEDBACK_URL"                        = var.webapp_config_feedback_url
    "GROVER_NO_SANDBOX"                   = var.webapp_config_grover_no_sandbox
    "GOOGLE_CLOUD_BUCKET"                 = var.webapp_config_google_cloud_bucket
    "NODE_ENV"                            = var.webapp_config_node_env
    "RAILS_ENV"                           = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT"                 = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"                    = var.webapp_config_rails_master_key
    "RAILS_MAX_THREADS"                   = var.webapp_config_rails_max_threads
    "RAILS_SERVE_STATIC_FILES"            = var.webapp_config_rails_serve_static_files
    "TRAINING_MODULES"                    = var.webapp_config_training_modules
    "WEB_CONCURRENCY"                     = var.webapp_config_web_concurrency
  }
  webapp_docker_image_url  = var.webapp_docker_image_url
  webapp_docker_image_tag  = var.webapp_docker_image_tag
  webapp_health_check_path = "/health"
  depends_on               = [module.network, module.database]
}