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

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
