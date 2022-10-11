# ------------------------------------------------------------------------------
# Pa11y CI
# ------------------------------------------------------------------------------
FROM node:latest

RUN apt-get update; \
    apt-get install -y chromium; \
    npm install --global --unsafe-perm puppeteer pa11y-ci

COPY .pa11yci /usr/config.json
COPY pa11y-docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]