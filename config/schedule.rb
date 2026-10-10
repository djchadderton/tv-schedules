set :output, "/tmp/tv-schedules-cron.log"
set :environment, ENV.fetch("RACK_ENV", "production")
set :environment_variable, "RACK_ENV"
set :path, "/app"
env "BUNDLE_PATH", "/usr/local/bundle"
env "BUNDLE_WITHOUT", "development"

every 1.day, at: "3:15 am" do
  rake "fetch_epg"
end
