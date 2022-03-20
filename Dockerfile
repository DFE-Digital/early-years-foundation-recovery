# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.1.0-alpine as base

RUN apk add --no-cache --no-progress build-base tzdata postgresql-dev yarn gcompat

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

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN bundle config set no-cache true
RUN bundle config set without development test
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
RUN bundle config set without test
RUN bundle install --no-binstubs --retry=10 --jobs=4

RUN yarn global add adr-log

# ------------------------------------------------------------------------------
# Test Stage
# ------------------------------------------------------------------------------
FROM app as test

RUN bundle config unset without
RUN bundle config set without development
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY .rspec ${APP_HOME}/.rspec
COPY spec ${APP_HOME}/spec
