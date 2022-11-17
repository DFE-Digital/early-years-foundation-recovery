paas_app_environment       = "content"
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_command = "bundle exec rails db:prepare db:seed && bundle exec rails server -b 0.0.0.0"

# Production like values
paas_postgres_service_plan = "medium-ha-13"
paas_web_app_memory = 512
# paas_web_app_start_timeout = 3600


# small-ha-xx took only 30 secs longer than 15 min limit
# tiny-unencrypted-xx was comfortably under 15 mins
paas_postgres_create_timeout = "20m"
