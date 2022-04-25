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

# data "cloudfoundry_domain" "service_gov_uk" {
#   name = "${var.service_name}.service.gov.uk"
# }

# data "cloudfoundry_domain" "education_gov_uk" {
#   name = "${var.service_name}.education.gov.uk"
# }

data "cloudfoundry_service" "postgres" {
  name = "postgres"
}
