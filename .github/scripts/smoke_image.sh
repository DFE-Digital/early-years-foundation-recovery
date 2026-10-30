#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: smoke_image.sh <image>}"

docker run --rm --entrypoint sh "${image}" -ec '
  bundle check
  for tool in gcc g++ make git yarn npm; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "Build tool unexpectedly present in runtime image: $tool" >&2
      exit 1
    fi
  done
  for package in build-base postgresql-dev yaml-dev; do
    if apk info --installed "$package" >/dev/null 2>&1; then
      echo "Build package unexpectedly present in runtime image: $package" >&2
      exit 1
    fi
  done
  if [ -z "$(find public/assets -name ".sprockets-manifest-*.json" -print -quit)" ]; then
    echo "Precompiled asset manifest is missing" >&2
    exit 1
  fi
  if [ ! -s public/govuk-assets/fonts/fa-solid-900.woff2 ]; then
    echo "Compiled font asset is missing" >&2
    exit 1
  fi
  /usr/sbin/sshd -t
  otelcol --version
  bundle exec ruby -rpg -rpsych -rnokogiri -ropenssl -rbootsnap -rgrover -e '\''
    abort "Asset build dependencies are present" if %w[esbuild sass stylelint govuk-frontend].any? { |name| File.directory?("node_modules/#{name}") }
    pdf = Grover.new("<html><body>Runtime PDF smoke check</body></html>",
                    executable_path: ENV.fetch("PUPPETEER_EXECUTABLE_PATH")).to_pdf
    abort "PDF generation failed" unless pdf.start_with?("%PDF-")
    puts "Native libraries and Chromium PDF generation passed"
  '\''
'
