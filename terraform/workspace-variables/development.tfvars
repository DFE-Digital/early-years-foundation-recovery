paas_app_environment       = "development"
paas_cf_space_name         = "ey-recovery-staging"
paas_web_app_instances     = 2
paas_web_app_start_command = "bundle exec rails db:prepare assets:precompile sitemap:refresh:no_ping && bundle exec rails server -b 0.0.0.0"
