# https://github.com/Studiosity/grover/blob/main/README.md#debugging
# The headless option disabled is not compatible with exporting of the PDF.
#
Grover.configure do |config| # DISABLED FOR DEBUGGING TEST SUITE
  config.options = { # DISABLED FOR DEBUGGING TEST SUITE
    executable_path: '/usr/bin/chromium-browser', # DISABLED FOR DEBUGGING TEST SUITE
    launch_args: [ # DISABLED FOR DEBUGGING TEST SUITE
      '--disable-gpu', # DISABLED FOR DEBUGGING TEST SUITE
      '--disable-dev-shm-usage', # DISABLED FOR DEBUGGING TEST SUITE
      '--font-render-hinting=none', # DISABLED FOR DEBUGGING TEST SUITE
    ], # DISABLED FOR DEBUGGING TEST SUITE
    format: 'A4', # DISABLED FOR DEBUGGING TEST SUITE
    margin: { # DISABLED FOR DEBUGGING TEST SUITE
      top: '0px', # DISABLED FOR DEBUGGING TEST SUITE
      bottom: '0px', # DISABLED FOR DEBUGGING TEST SUITE
      left: '20px', # DISABLED FOR DEBUGGING TEST SUITE
      right: '20px', # DISABLED FOR DEBUGGING TEST SUITE
    }, # DISABLED FOR DEBUGGING TEST SUITE
  } # DISABLED FOR DEBUGGING TEST SUITE
end # DISABLED FOR DEBUGGING TEST SUITE
