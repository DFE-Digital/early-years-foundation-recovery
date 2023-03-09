paas_app_environment       = "content"
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_command = "bundle exec rails db:prepare assets:precompile db:seed && bundle exec rails server -b 0.0.0.0"
