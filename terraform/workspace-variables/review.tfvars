paas_app_environment       = "review"
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_timeout = 360  # default: 300
paas_web_app_memory        = 1024 # default: 512
paas_web_app_start_command = "bundle exec rake db:prepare db:seed && bundle exec rails s -b 0.0.0.0"
