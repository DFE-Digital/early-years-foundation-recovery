# ------------------------------------------------------------------------------
# Pa11y
# ------------------------------------------------------------------------------
FROM buildkite/puppeteer:latest

RUN apt-get update; \
    apt-get install -qq -y rpl --fix-missing --no-install-recommends; \
    npm install --global --unsafe-perm pa11y-ci

COPY .pa11yci /usr/config.json
COPY pa11y-docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]