paas_app_environment       = "review" # see: app_config.yml
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_command = "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"
paas_web_app_memory        = 1024 # default: 512
# paas_web_app_start_timeout = 360  # default: 300
