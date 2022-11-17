paas_app_environment       = "content"
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_command = "bundle exec rails db:prepare db:seed && bundle exec rails server -b 0.0.0.0"

# Production like values
paas_postgres_service_plan = "small-ha-13"
paas_web_app_memory = 512
