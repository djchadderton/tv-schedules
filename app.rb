require "sinatra"
require "sinatra/activerecord"
# require "json"

require_relative "models/channel"
require_relative "models/programme"

get "/" do
  date = Date.today

  @sorted_programmes = Programme.joins(:channel)
    .where(starts_at: date.beginning_of_day.., channel_id: SELECTED_CHANNELS)
    .order(:starts_at)
    .includes(:channel)
    .group_by(&:channel_id)

  # @schedule_data = programmes.map do |programme|
  #   {
  #     programme_id: programme.id,
  #     title: programme.title,
  #     description: programme.description,
  #     starts_at: programme.starts_at,
  #     ends_at: programme.ends_at,
  #     series: programme.series,
  #     episode: programme.episode,
  #     premiere: programme.premiere,
  #     channel_name: programme.channel_name,
  #     duration_minutes: programme.duration_minutes
  #   }.to_json
  # end
  erb :schedule_view, layout: :application
end

get "/channels" do
  redirect "/channels/"
end

get "/channels/" do
  Channel.all.map do |channel|
    "<p>Channel: <a href='/channels/#{channel.channel_id}'>#{channel.name}</a></p>"
  end.join
end

get "/channels/:id" do
  channel = Channel.find_by(channel_id: params[:id])
  "<p>Channel: #{channel.name}</p><p>Programmes: <ul><li>#{channel.programmes.map { "#{it.starts_at}: #{it.title}" }.join("</li><li>")}</li></ul></p>"
end

get "/up" do
  "OK"
end

helpers do
  def position_style(start_minutes, duration_minutes)
    "left: #{start_minutes * 10}px; width: #{duration_minutes * 10}px;"
  end
end
