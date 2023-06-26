require 'grover'

Grover.configure do |config|
  config.options = {
    executable_path: '/usr/bin/chromium-browser',
    launch_args: ['--disable-dev-shm-usage'],
  }
end
