#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Check installed gems if missing
if [[ "$RAILS_ENV" == "development" ]]
then
	bundle check || bundle install
fi

# Only needed one time during development
if [[ "$RAILS_ENV" == "development" ]]
then
	bundle exec rails db:create
fi

bundle exec rails db:migrate 2>/dev/null
#  || bundle exec rails db:setup

# # No need to seed to prepare database in production/staging
if [[ "$RAILS_ENV" == "test" ]]
then
	bundle exec rails db:test:prepare
fi

# Refresh roles and permissions
bundle exec rails refresh:roles_and_permissions 2>/dev/null

# If yarn isn't already run
if [[ "$RAILS_ENV" == "development" ]]
then
	bundle exec rails yarn:install
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
