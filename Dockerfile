# ------------------------------------------------------------------------------
# OpenTelemetry Collector
# ------------------------------------------------------------------------------
FROM otel/opentelemetry-collector-contrib:0.163.2@sha256:7f22d2a6748110ffb6a59bc0df448bccbf501cdb667d610ede4c61d3863d5849 AS otel-collector

# ------------------------------------------------------------------------------
# Runtime base - AMD64 & ARM64 compatible
# ------------------------------------------------------------------------------
FROM ruby:3.4.10-alpine3.23 AS base

RUN apk upgrade --no-cache --no-progress \
    && apk add --no-cache --no-progress \
    ca-certificates chromium font-liberation libpq yaml nodejs openssh tzdata

RUN echo "Welcome to the EYFS Recovery Application" > /etc/motd \
    && echo "root:Docker!" | chpasswd \
    && ssh-keygen -A \
    && mkdir -p /run/sshd /srv/tmp/pids /srv/log

ENV TZ=Europe/London \
    GROVER_NO_SANDBOX=true \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    APP_HOME=/srv \
    RAILS_ENV=production \
    ENVIRONMENT=production

WORKDIR ${APP_HOME}

COPY sshd_config /etc/ssh/
COPY docker-entrypoint.sh /
COPY --from=otel-collector /otelcol-contrib /usr/bin/otelcol
COPY otel-collector-config.yml /etc/otel-collector-config.yml
COPY otel-collector-azure-config.yml /etc/otel-collector-azure-config.yml
COPY otel-collector-entrypoint.sh /usr/local/bin/otel-collector-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["sh", "-c", "/usr/local/bin/otel-collector-entrypoint.sh >/dev/null 2>&1 & exec bundle exec rails server"]

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
FROM base AS deps

LABEL org.opencontainers.image.description="Application Dependencies"

RUN apk add --no-cache --no-progress build-base git postgresql-dev yaml-dev

COPY .yarn/releases/yarn-4.18.0.cjs /usr/local/lib/yarn.cjs
RUN chmod +x /usr/local/lib/yarn.cjs && ln -s /usr/local/lib/yarn.cjs /usr/local/bin/yarn

COPY package.json ${APP_HOME}/package.json
COPY yarn.lock ${APP_HOME}/yarn.lock
COPY .yarn ${APP_HOME}/.yarn
COPY .yarnrc.yml ${APP_HOME}/.yarnrc.yml

RUN yarn install --immutable

COPY Gemfile* ./

RUN bundle config set no-cache true
RUN bundle config set without development test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Build application assets
# ------------------------------------------------------------------------------
FROM deps AS build

COPY config.ru ${APP_HOME}/config.ru
COPY Rakefile ${APP_HOME}/Rakefile
COPY public ${APP_HOME}/public
COPY bin ${APP_HOME}/bin
COPY lib ${APP_HOME}/lib
COPY data ${APP_HOME}/data
COPY config ${APP_HOME}/config
COPY db ${APP_HOME}/db
COPY app ${APP_HOME}/app

RUN mkdir -p app/assets/builds
RUN yarn build:css && yarn build
RUN yarn run copy:assets
RUN SECRET_KEY_BASE=x bundle exec rails assets:precompile

# ------------------------------------------------------------------------------
# Production dependencies - only Puppeteer is needed after assets are compiled
# ------------------------------------------------------------------------------
FROM build AS production-deps

RUN yarn workspaces focus --production \
    && rm -rf .yarn /usr/local/bundle/cache

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM base AS app

LABEL org.opencontainers.image.source=https://github.com/DFE-Digital/early-years-foundation-recovery
LABEL org.opencontainers.image.description="Early Years Recovery Rails Application"

COPY --from=production-deps /usr/local/bundle /usr/local/bundle
COPY --from=production-deps /srv /srv

# ------------------------------------------------------------------------------
# Development Stage - ./bin/docker-dev
# ------------------------------------------------------------------------------
FROM build AS dev

# `socat` is used by Procfile.dev to forward 127.0.0.1:4000 inside this container
RUN apk add --no-cache --no-progress postgresql-client npm graphviz socat less curl
RUN npm install --global adr-log contentful-cli

RUN bundle config unset without
RUN bundle config set without test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Test Stage - ./bin/docker-rspec
# ------------------------------------------------------------------------------
FROM build AS test

RUN apk add --no-cache --no-progress postgresql-client

RUN bundle config unset without
RUN bundle config set without development ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY spec ${APP_HOME}/spec
COPY .rspec ${APP_HOME}/.rspec
COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml

CMD ["bundle", "exec", "rspec"]

# ------------------------------------------------------------------------------
# Pa11y CI - ./bin/docker-pa11y
# ------------------------------------------------------------------------------
FROM base AS pa11y

LABEL org.opencontainers.image.description "Accessibility auditor"

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_SKIP_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser

RUN apk add --no-cache --no-progress npm
RUN npm install --global --unsafe-perm puppeteer pa11y-ci

COPY .pa11yci /usr/config.json
COPY docker-entrypoint.pa11y.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
