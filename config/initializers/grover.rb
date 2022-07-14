# config/initializers/grover.rb
Grover.configure do |config|
  config.options = {
    executable_path: '/usr/bin/chromium-browser',
  }
end
