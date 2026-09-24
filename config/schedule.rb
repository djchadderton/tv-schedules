set :output, "/tmp/tv-schedules-cron.log"
set :environment, "development"

every 1.day, at: "3:15 am" do
  rake "fetch_epg"
end
