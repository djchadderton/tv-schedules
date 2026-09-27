# TV Schedules

A small Sinatra + ActiveRecord app for displaying a TV programme guide from an XMLTV-style EPG feed.

The app imports live schedule data, stores it in SQLite, and renders a simple grid with:

- channels down the left
- time slots across the top
- programme blocks grouped by date
- hyperlink/date navigation
- current time indicator
- dark/light mode support

## Features

- Fetches and stores channel and programme metadata from a remote XML feed
- Shows the selected day as a schedule grid
- Supports day navigation and a direct jump to today
- Highlights programmes that have already ended
- Displays programme details in a popover on hover/click/tap
- Uses the browser or OS colour preference for default theme rendering
- Can prune expired programmes before the current day as part of the import process
- Includes a `whenever` schedule for automatic daily refreshes

## Requirements

- Ruby 3.x
- Bundler
- SQLite

## Installation

```bash
bundle install
```

## Database setup

This project uses SQLite via ActiveRecord. The database configuration is defined in `config/database.yml` and the schema is managed in `db/schema.rb` and the migration files under `db/migrate/`.

If you need to initialise the database from the current schema:

```bash
bundle exec rake db:create db:schema:load
```

## Importing programme data

Fetch the latest EPG data and save it to the database:

```bash
bundle exec rake fetch_epg
```

This runs the importer in `schedule.rb`, updates channel data, stores programmes, and removes out-of-date entries before the current day.

## Running the app

Start the Sinatra app:

```bash
bundle exec rackup
```

Then open the app in your browser, usually at:

```text
http://localhost:9292/
```

## Daily updates

A cron configuration exists in `config/schedule.rb` and uses the `whenever` gem to refresh the feed every day at 03:15.

To install the cron job:

```bash
bundle exec whenever --update-crontab
```

## Deployment with Kamal 2

The repository includes a Kamal configuration in `config/deploy.yml` for deployment to the Raspberry Pi at `192.168.0.33` using a built-in registry.

Before deploying, set the required environment variables:

```bash
export GITHUB_USERNAME=your-github-user
export GITHUB_TOKEN=your-github-personal-access-token
export APP_SECRET=some-long-random-secret
```

Then run:

```bash
kamal setup
kamal deploy
```

This builds an ARM64 image for the target Pi, pushes it to the configured registry, deploys the app, and persists the SQLite database in the Docker volume configured under `config/deploy.yml`.

## Project structure

- `app.rb` – Sinatra routes and schedule view logic
- `schedule.rb` – feed parsing and import logic
- `models/` – ActiveRecord models
- `views/` – ERB templates
- `public/` – static assets and JavaScript
- `config/` – database and cron configuration
- `db/` – schema and migrations

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
