# Using alpine image for small size
FROM ruby:3.1.0-alpine

# Install runtime dependencies
RUN apk update && apk add --update tzdata shared-mime-info git

# Use virtual build-dependencies tag so we can remove these packages after bundle install
RUN apk add --update --no-cache --virtual build-dependency libxml2-dev libxslt-dev build-base ruby-dev postgresql-dev libcurl

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /var/www/proxycrawler/api

# make a new directory where our project will be copied
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set working directory within container
WORKDIR $RAILS_ROOT

# Setting env up
ARG RAILS_ENV
ENV RAILS_ENV $RAILS_ENV
ENV RAKE_ENV $RAILS_ENV
ENV RACK_ENV $RAILS_ENV
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE $SECRET_KEY_BASE

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN gem install bundler -v 2.2.33

# nokogiri now bundles its own libxml2, which doesn't compile on alpine
RUN bundle config build.nokogiri --use-system-libraries

# development/production differs in bundle install
RUN if [[ "$RAILS_ENV" == "test" ]]; then\
 bundle check || bundle install --jobs 8 --retry 5 --without development;\
 elif [[ "$RAILS_ENV" != "development" ]]; then\
 bundle check || bundle install --jobs 8 --retry 5 --without development test;\
 else bundle check || bundle install; fi

# Remove build dependencies and install runtime dependencies
RUN if [[ "$RAILS_ENV" != "development" ]]; then\
  apk del build-dependency &&\
  apk add --update libxml2 libxslt postgresql-client postgresql-libs libcurl; fi

# Adding project files
COPY . .

# Use ruby's jit in time compiler for better performance
ENV RUBY_OPT "--yjit"

ENTRYPOINT [ "entrypoint.sh" ]

CMD [ "sneakers", "work", "GetUrlsWorker", "--require", "config/preload.rb" ]
