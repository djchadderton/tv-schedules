set :output, "/tmp/tv-schedules-cron.log"
set :environment, ENV.fetch("RACK_ENV", "production")
set :chdir, "/app"

every 1.day, at: "3:15 am" do
  rake "fetch_epg"
end
