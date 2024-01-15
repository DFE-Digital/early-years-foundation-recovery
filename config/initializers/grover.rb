# https://github.com/Studiosity/grover/blob/main/README.md#debugging
# The headless option disabled is not compatible with exporting of the PDF.
#
Grover.configure do |config|
  config.options = {
    executable_path: '/usr/bin/chromium-browser',
    launch_args: ['--disable-dev-shm-usage'],
    format: 'A4',
    margin: {
      top: '20px',
      bottom: '20px',
      left: '20px',
      right: '20px',
    },
  }
end
