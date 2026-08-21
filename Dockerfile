# ------------------------------------------------------------------------------
# Build base - AMD64 & ARM64 compatible
# ------------------------------------------------------------------------------
FROM ruby:3.4.6-bookworm AS build-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=Europe/London

# ------------------------------------------------------------------------------
# Ruby gem dependencies
# ------------------------------------------------------------------------------
FROM build-base AS deps

LABEL org.opencontainers.image.description "Application Dependencies"

ENV APP_HOME=/build
WORKDIR ${APP_HOME}

COPY Gemfile* ./

RUN bundle config set no-cache true \
    && bundle config set without "development test ui" \
    && bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# JavaScript/CSS asset compilation
# ------------------------------------------------------------------------------
FROM build-base AS assets

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    chromium \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global yarn

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV RAILS_ENV=production
ENV APP_HOME=/build

WORKDIR ${APP_HOME}

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install

COPY --from=deps /usr/local/bundle /usr/local/bundle
COPY Gemfile* ./
COPY config.ru Rakefile ./
COPY public ./public
COPY bin ./bin
COPY lib ./lib
COPY config ./config
COPY db ./db
COPY app ./app

RUN mkdir -p app/assets/builds \
    && yarn build:css \
    && yarn build \
    && yarn run copy:assets \
    && SECRET_KEY_BASE=x bundle exec rails assets:precompile

# ------------------------------------------------------------------------------
# OpenTelemetry Collector
# ------------------------------------------------------------------------------
FROM otel/opentelemetry-collector-contrib:latest AS otel-collector

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM ruby:3.4.6-slim-bookworm AS app

LABEL org.opencontainers.image.source=https://github.com/DFE-Digital/early-years-foundation-recovery
LABEL org.opencontainers.image.description "Early Years Recovery Rails Application"

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    fonts-liberation \
    libpq5 \
    libyaml-0-2 \
    openssh-server \
    curl \
    tzdata \
    less \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Welcome to the EYFS Recovery Application" > /etc/motd \
    && echo "root:Docker!" | chpasswd \
    && cd /etc/ssh/ && ssh-keygen -A

ENV GROVER_NO_SANDBOX=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV TZ=Europe/London
ENV APP_HOME=/srv
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV ENVIRONMENT=${ENVIRONMENT:-production}

RUN mkdir -p ${APP_HOME}/tmp/pids ${APP_HOME}/log

WORKDIR ${APP_HOME}

COPY Gemfile* ./
COPY --from=deps /usr/local/bundle /usr/local/bundle

COPY config.ru ${APP_HOME}/config.ru
COPY Rakefile ${APP_HOME}/Rakefile
COPY bin ${APP_HOME}/bin
COPY lib ${APP_HOME}/lib
COPY data ${APP_HOME}/data
COPY config ${APP_HOME}/config
COPY db ${APP_HOME}/db
COPY app ${APP_HOME}/app

# Copy precompiled public assets from the assets stage
COPY --from=assets /build/public ${APP_HOME}/public

COPY sshd_config /etc/ssh/
COPY ./docker-entrypoint.sh /

# Install OpenTelemetry Collector
COPY --from=otel-collector /otelcol-contrib /usr/bin/otelcol
COPY otel-collector-config.yml /etc/otel-collector-config.yml

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

# Start Collector in background, then Rails
CMD ["sh", "-c", "otelcol --config=/etc/otel-collector-config.yml >/dev/null 2>&1 & exec bundle exec rails server"]

# ------------------------------------------------------------------------------
# Development Stage - ./bin/docker-dev
# ------------------------------------------------------------------------------
FROM app AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    nodejs \
    npm \
    graphviz \
    socat \
    && rm -rf /var/lib/apt/lists/*

# `socat` is used by Procfile.dev to forward 127.0.0.1:4000 inside this container
RUN npm install --global yarn adr-log contentful-cli

RUN bundle config unset without \
    && bundle config set without "test ui" \
    && bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Test Stage - ./bin/docker-rspec
# ------------------------------------------------------------------------------
FROM app AS test

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN bundle config unset without \
    && bundle config set without "development ui" \
    && bundle install --no-binstubs --retry=10 --jobs=4

COPY spec ${APP_HOME}/spec
COPY .rspec ${APP_HOME}/.rspec
COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml

CMD ["bundle", "exec", "rspec"]

# ------------------------------------------------------------------------------
# Pa11y CI - ./bin/docker-pa11y
# ------------------------------------------------------------------------------
FROM build-base AS pa11y

LABEL org.opencontainers.image.description "Accessibility auditor"

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    chromium \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global --unsafe-perm puppeteer pa11y-ci

COPY .pa11yci /usr/config.json
COPY docker-entrypoint.pa11y.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
