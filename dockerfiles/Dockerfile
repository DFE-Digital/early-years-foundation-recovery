# ***WIP*** FEEL FREE TO MODIFY AND AMEND.
# To build the UI test environment the following items are required:
    # A machine to run the tests
    # the latest stable Ruby version
    # Installation of the necessary Rubygems
    # A browser to run the tests
    # Potentially use a Raketask to execute the ui tests, otherwise use the existing shell script

FROM ruby:3.1.0-alpine

# Untested!!
ARG APP_DIR='/workspace/app'

# Set the environment for the tests to run against (in this case the Heroku instance).
# Should be noted that the env should be updated when testing against any other environment
ENV ENV=int

# Use a headless chrome browser
ENV BROWSER=headless_chrome

# install latest chrome browser
RUN apt-get update || true && apt-get -y install unzip wget curl vim \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes google-chrome-stable \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && sed -i 's/"$APP_DIR\/chrome"/"$APP_DIR\/chrome" --headless --disable-dev-shm-usage --no-sandbox/g' /opt/google/chrome/google-chrome \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

