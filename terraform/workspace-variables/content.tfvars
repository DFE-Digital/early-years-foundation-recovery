paas_app_environment       = "content"
paas_cf_space_name         = "ey-recovery-content"
paas_web_app_start_command = "rm public/robots.txt && bundle exec rails db:prepare db:seed && bundle exec rails server -b 0.0.0.0"
