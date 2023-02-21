paas_app_environment         = "production"
paas_cf_space_name           = "ey-recovery"
paas_postgres_service_plan   = "medium-ha-13"
paas_postgres_create_timeout = "20m"
paas_web_app_memory          = 4096 # TODO: change to string format to support "4G"
paas_web_app_instances       = 3
paas_web_app_start_command   = "rm public/robots.txt && touch public/robots.txt && bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"
