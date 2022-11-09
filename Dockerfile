# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.1.2-alpine as base

RUN apk add --no-cache --no-progress build-base less curl tzdata gcompat \
    "busybox>=1.34.1-r5" \
    "gmp>=6.2.1-r1" \
    "libretls>=3.3.4-r3" \
    "ncurses-libs>=6.3_p20211120-r1" \
    "nodejs>=16.16.0-r0" \
    "ssl_client>=1.34.1-r5" \
    "zlib>=1.2.12-r0"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
FROM base as deps

LABEL org.opencontainers.image.description "Application Dependencies"

RUN apk add --no-cache --no-progress postgresql-dev yarn chromium

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
ENV APP_HOME /build

WORKDIR ${APP_HOME}

COPY package.json ${APP_HOME}/package.json
COPY yarn.lock ${APP_HOME}/yarn.lock
COPY .yarn ${APP_HOME}/.yarn
COPY .yarnrc.yml ${APP_HOME}/.yarnrc.yml

RUN yarn install

COPY Gemfile* ./

RUN bundle config set no-cache true
RUN bundle config set without development test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Production Stage - nodejs v16.17.1, postgresql v14.5, chromium v102.0.5005.182
# ------------------------------------------------------------------------------
FROM base AS app

LABEL org.opencontainers.image.description "Early Years Recovery Rails Application"

RUN apk add --no-cache --no-progress postgresql-dev yarn chromium

ENV GROVER_NO_SANDBOX true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
ENV APP_HOME /srv
ENV RAILS_ENV ${RAILS_ENV:-production}

COPY .docker-profile /root/.profile

RUN mkdir -p ${APP_HOME}/tmp/pids ${APP_HOME}/log

WORKDIR ${APP_HOME}

COPY Gemfile* ./
COPY --from=deps /usr/local/bundle /usr/local/bundle

COPY config.ru ${APP_HOME}/config.ru
COPY Rakefile ${APP_HOME}/Rakefile
COPY public ${APP_HOME}/public
COPY bin ${APP_HOME}/bin
COPY lib ${APP_HOME}/lib
COPY data ${APP_HOME}/data
COPY config ${APP_HOME}/config
COPY db ${APP_HOME}/db
COPY app ${APP_HOME}/app

COPY package.json ${APP_HOME}/package.json
COPY yarn.lock ${APP_HOME}/yarn.lock
COPY .yarnrc.yml ${APP_HOME}/.yarnrc.yml
COPY --from=deps /build/.yarn ${APP_HOME}/.yarn
COPY --from=deps /build/node_modules ${APP_HOME}/node_modules

RUN SECRET_KEY_BASE=x \
    GOVUK_APP_DOMAIN=x \
    GOVUK_WEBSITE_ROOT=x \
    bundle exec rails assets:precompile

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]

# ------------------------------------------------------------------------------
# Development Stage
# ------------------------------------------------------------------------------
FROM app as dev

RUN apk add --no-cache --no-progress npm graphviz
RUN npm install --global adr-log

RUN bundle config unset without
RUN bundle config set without test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Test Stage
# ------------------------------------------------------------------------------
FROM app as test

RUN bundle config unset without
RUN bundle config set without development ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY spec ${APP_HOME}/spec
COPY .rspec ${APP_HOME}/.rspec
COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml

CMD ["bundle", "exec", "rspec"]

# ------------------------------------------------------------------------------
# Test UI Stage (additional non-Ruby dependencies, containerised version of local dev experience)
# ------------------------------------------------------------------------------
FROM app as ui

RUN bundle config unset without
RUN bundle config set without development
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY ui ${APP_HOME}/ui

CMD ["bundle", "exec", "rspec", "--default-path", "ui"]

# ------------------------------------------------------------------------------
# QA Stage (self-contained and headless for pipeline)
# ------------------------------------------------------------------------------
FROM base as qa

RUN gem install pry-byebug rspec capybara site_prism selenium-webdriver faker dry-inflector

WORKDIR /srv

COPY ui /srv/spec
COPY .rspec /srv/.rspec

CMD ["rspec"]

# ------------------------------------------------------------------------------
# Pa11y CI
# ------------------------------------------------------------------------------
FROM base as pa11y

LABEL org.opencontainers.image.description "Accessibility auditor"

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser

RUN apk add --no-cache --no-progress npm chromium
RUN npm install --global --unsafe-perm puppeteer pa11y-ci

COPY .pa11yci /usr/config.json
COPY docker-entrypoint.pa11y.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
