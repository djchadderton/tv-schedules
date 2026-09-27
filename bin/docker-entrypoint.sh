#!/usr/bin/env bash
set -euo pipefail

export RACK_ENV="${RACK_ENV:-production}"
cd /app

if [ ! -f db/production.sqlite3 ]; then
  echo "Initializing SQLite database..."
  bundle exec rake db:create db:schema:load RACK_ENV=production
else
  echo "Running database migrations..."
  bundle exec rake db:migrate RACK_ENV=production
fi

bundle exec whenever --update-crontab

if command -v cron >/dev/null 2>&1; then
  if ! pgrep -x cron >/dev/null 2>&1; then
    echo "Starting cron daemon..."
    cron -f >/tmp/tv-schedules-cron.log 2>&1 &
  fi
fi

if bundle exec ruby -e 'require "./app"; exit(Channel.count.zero? ? 0 : 1)' >/dev/null 2>&1; then
  echo "No programme data found; importing initial feed..."
  bundle exec rake fetch_epg RACK_ENV=production
fi

exec "$@"
