ARG RUBY_VERSION=4.0.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim

WORKDIR /app

ENV BUNDLE_WITHOUT="development" \
  BUNDLE_PATH="/usr/local/bundle" \
  RACK_ENV=production \
  PORT=9292

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  libsqlite3-dev \
  pkg-config \
  sqlite3 \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development' \
  && bundle install --jobs 4 --retry 3

COPY . .

RUN chmod +x ./bin/docker-entrypoint.sh

EXPOSE 9292

ENTRYPOINT ["./bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "9292"]
