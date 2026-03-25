source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.5'

gem 'pg'
gem 'puma'
gem 'rails'
gem 'rexml', '>= 3.4.2'
gem 'sprockets-rails'
gem 'uri', '>= 1.0.4'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'cssbundling-rails'
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Users
gem 'devise'
gem 'dibber'
gem 'jwt'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'

# HTML abstraction markup language
gem 'slim-rails'

# Headless CMS
gem 'contentful_rails'

# TODO: add ey-recovery to https://github.com/DFE-Digital/govuk-components
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'

# # Markdown support
gem 'govuk_markdown'

# Email
gem 'govuk_notify_rails'

# Monitor errors
gem 'sentry-rails'

# Azure Application Insights / OpenTelemetry
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-active_record'
gem 'opentelemetry-instrumentation-http'
gem 'opentelemetry-instrumentation-net_http'
gem 'opentelemetry-instrumentation-rack'
gem 'opentelemetry-instrumentation-rails'
gem 'opentelemetry-sdk'

# Track users
gem 'ahoy_matey'

# PDF generator middleware
gem 'grover'

# Pa11y accessibility testing
gem 'sitemap_generator'

# Data dashboard feed
gem 'csv'
gem 'google-cloud-storage'

# Background Jobs
gem 'que-scheduler'

# DRY-RB
gem 'dry-core'
gem 'dry-initializer'
gem 'dry-struct'
gem 'dry-types'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'faker'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-govuk', require: false
  gem 'rubocop-performance', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'pry-doc'
  gem 'rack-mini-profiler'
  gem 'rails-erd'
  gem 'redcarpet'
  gem 'web-console'
  gem 'yard-junk'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'show_me_the_cookies'
  gem 'simplecov'
end
