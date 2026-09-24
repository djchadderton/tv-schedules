require "sinatra/activerecord/rake"

desc "Starts up a development server that autostarts when a file changes"
task :dev do
  system "bundler exec rackup"
end

desc "Builds a Docker image and runs"
task :build do
  system "docker build . -t app && docker run -it --rm -p 3000:3000 app"
end

desc "Fetches the EPG data, stores it, and removes old programmes"
task :fetch_epg do
  require "./schedule"
  schedule = Schedule.new.import!
  puts "Imported #{schedule.channels.size} channels and #{schedule.programmes.size} programmes; removed #{schedule.removed_programmes} old programmes."
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
