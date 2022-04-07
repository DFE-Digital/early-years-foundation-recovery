require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'

Capybara.server_host = 'app'

chrome_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
chrome_capabilities['acceptInsecureCerts'] = true

firefox_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
firefox_capabilities['acceptInsecureCerts'] = true

# Example against dev server using chrome
# 1. bundle exec rails s
# 2. BASE_URL=http://localhost:3000 bundle exec rspec --default-path ui
#
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 capabilities: chrome_capabilities)
end

# Example against production container using firefox
# 1. docker start recovery_prod
# 2. BROWSER=firefox bundle exec rspec --default-path ui
#
Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :firefox,
                                 capabilities: firefox_capabilities)
end

# Only accessible inside Docker -----------
# unless we open and map ports

Capybara.register_driver :standalone_chrome do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :remote,
                                 url: 'http://chrome:4444/wd/hub',
                                 capabilities: chrome_capabilities)
end

Capybara.register_driver :standalone_firefox do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :remote,
                                 url: 'http://firefox:4444/wd/hub',
                                 capabilities: firefox_capabilities)
end
