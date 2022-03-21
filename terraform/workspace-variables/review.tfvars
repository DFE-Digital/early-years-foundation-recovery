# Platform
environment = "production"

# Gov.UK PaaS Module
paas_app_environment = "production"
paas_app_start_timeout = "360"
paas_web_app_memory = 1024
paas_web_app_start_command = "bundle exec rake db:prepare db:seed && bundle exec rails s -b 0.0.0.0"
