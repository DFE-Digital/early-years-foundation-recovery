# https://github.com/Studiosity/grover/blob/main/README.md#debugging
# The headless option disabled is not compatible with exporting of the PDF.
#
Grover.configure do |config|
  config.options = {
    executable_path: '/usr/bin/chromium-browser',
    launch_args: [
      '--disable-gpu',
      '--disable-dev-shm-usage',
      '--font-render-hinting=none',
    ],
    format: 'A4',
    margin: {
      top: '0px',
      bottom: '0px',
      left: '20px',
      right: '20px',
    },
  }
end
