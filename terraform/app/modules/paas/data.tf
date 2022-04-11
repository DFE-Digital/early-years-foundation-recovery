data "cloudfoundry_org" "org" {
  name = "dfe"
}

data "cloudfoundry_space" "space" {
  name = var.cf_space_name
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "cloudapps_digital" {
  name = "london.cloudapps.digital"
}

# data "cloudfoundry_domain" "recovery_service_gov_uk" {
#   name = "eyfs-recovery.service.gov.uk"
# }

# data "cloudfoundry_domain" "recovery_education_gov_uk" {
#   name = "eyfs-recovery.education.gov.uk"
# }

data "cloudfoundry_service" "postgres" {
  name = "postgres"
}
