FROM ruby:2.5-alpine

# Install static prerequisits
RUN apk add --no-cache \
      wget \
      unzip \
      # dependencies for gems
      build-base \
      cmake \
      linux-headers \
      mariadb-dev \
      # dependencies for runtime
      nodejs \
      yarn \
      && \
    # Permissions for OpenShift compatibility
    mkdir /opt && \
    chown -R 1001:0 /opt && chmod -R g=u /opt && \
    chmod g=u /etc/passwd

# from now on - do everything unprivileged
USER 1001

# Define lobsters "version"
# Note: There is no official release, so we stick to a Git hash
# This is also used for build cache invalidation
ENV LOBSTERS_HASH=33b333c \
    RAILS_ENV=openshift \
    HOME=/opt/lobsters

# Install lobsters
RUN cd /opt && \
    wget -q https://github.com/lobsters/lobsters/archive/${LOBSTERS_HASH}.zip >/dev/null && \
    unzip ${LOBSTERS_HASH}.zip >/dev/null && rm ${LOBSTERS_HASH}.zip && \
    cd lobsters-* && cp -r . /opt/lobsters && cd /opt && rm -rf lobsters-* && \
    cd /opt/lobsters && \
    # Adding missing Gem
    echo "gem \"tzinfo-data\"" >> Gemfile && \
    bundle install --without="test development"

# from now on - do everything in /opt/lobsters
WORKDIR /opt/lobsters

ADD bin/entrypoint /usr/local/bin/entrypoint
ADD appcfg/database.yml /opt/lobsters/config/database.yml
ADD appcfg/env_openshift.rb /opt/lobsters/config/environments/openshift.rb
ADD appcfg/initializers_production.rb /opt/lobsters/config/initializers/openshift.rb

# OpenShift / Docker specific configuration
RUN \
  # Configure secret_key_base via environment vars
  echo "Lobsters::Application.config.secret_key_base = ENV['SECRET_KEY_BASE']" > /opt/lobsters/config/initializers/secret_token.rb

# Fix permissions for OpenShift
USER root
RUN chmod -R g=u /opt/lobsters
USER 1001

EXPOSE 3000
ENTRYPOINT [ "entrypoint" ]
CMD ["rails", "server"]
