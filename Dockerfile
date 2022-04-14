# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.1.0-alpine as base

RUN apk add --no-cache --no-progress \
    build-base curl tzdata postgresql-dev yarn gcompat \
    "gmp>=6.2.1-r1" "zlib>=1.2.12-r0" "busybox>=1.34.1-r5"  \
    "libretls>=3.3.4-r3" "libssl1.1>=1.1.1n-r0" "libcrypto1.1>=1.1.1n-r0"

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM base AS app

# ENV RAILS_ENV
# ENV RAILS_MASTER_KEY

ENV APP_HOME /src
ENV PATH $PATH:/usr/local/bundle/bin:/usr/local/bin

RUN mkdir -p ${APP_HOME}/tmp/pids ${APP_HOME}/log

WORKDIR ${APP_HOME}

COPY Gemfile* ./

RUN bundle config set no-cache true
RUN bundle config set without development test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY config.ru ${APP_HOME}/config.ru
COPY Rakefile ${APP_HOME}/Rakefile
COPY public ${APP_HOME}/public
COPY bin ${APP_HOME}/bin
COPY data ${APP_HOME}/data
COPY config ${APP_HOME}/config
COPY db ${APP_HOME}/db
COPY app ${APP_HOME}/app
COPY package.json ${APP_HOME}/package.json
COPY yarn.lock ${APP_HOME}/yarn.lock

RUN yarn; \
    yarn build; \
    yarn build:css

RUN bundle exec rails assets:precompile

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]

# ------------------------------------------------------------------------------
# Development Stage
# ------------------------------------------------------------------------------
FROM app as dev

RUN bundle config unset without
RUN bundle config set without test ui
RUN bundle install --no-binstubs --retry=10 --jobs=4

RUN yarn global add adr-log

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

RUN apk add --no-cache --no-progress \
        chromium-chromedriver

RUN bundle config unset without
RUN bundle config set without development
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY ui ${APP_HOME}/ui

CMD ["bundle", "exec", "rspec", "--default-path", "ui"]


# ------------------------------------------------------------------------------
# QA Stage (self-contained and headless for pipeline)
# ------------------------------------------------------------------------------
FROM ruby:3.1.0-alpine as qa

RUN apk add --no-cache --no-progress build-base tzdata gcompat \
    "gmp>=6.2.1-r1" "zlib>=1.2.12-r0" \
    "libretls>=3.3.4-r3" "libssl1.1>=1.1.1n-r0" "libcrypto1.1>=1.1.1n-r0"

RUN gem install pry-byebug rspec capybara site_prism selenium-webdriver

WORKDIR /src

COPY ui /src/spec
COPY .rspec /src/.rspec

CMD ["rspec"]