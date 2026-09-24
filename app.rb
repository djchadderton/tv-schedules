require "sinatra"
require "sinatra/activerecord"
# require "json"

require_relative "models/channel"
require_relative "models/programme"

get "/" do
  date = begin
    Date.iso8601(params["date"])
  rescue Date::Error, TypeError
    Date.today
  end

  latest_programme_date = Programme.maximum(:starts_at)&.getlocal&.to_date
  @last_schedule_date = [latest_programme_date || Date.today, Date.today].max
  @schedule_date = (date || Date.today).clamp(Date.today, @last_schedule_date)
  @theme = %w[dark light].include?(params["theme"]) ? params["theme"] : "system"
  @dark_mode = @theme == "dark"
  @light_mode = @theme == "light"

  programmes = Programme.joins(:channel)
    .where(starts_at: @schedule_date.beginning_of_day..@schedule_date.end_of_day, channel_id: SELECTED_CHANNELS)
    .order(:starts_at)
    .includes(:channel)
    .group_by(&:channel_id)

  channels = Channel.where(channel_id: SELECTED_CHANNELS).index_by(&:channel_id)
  @schedule_rows = SELECTED_CHANNELS.map do |channel_id|
    {
      channel_id: channel_id,
      channel: channels[channel_id],
      programmes: programmes.fetch(channel_id, [])
    }
  end

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
  def schedule_path(date: @schedule_date, theme: @theme || "system")
    date ||= Date.today
    query = URI.encode_www_form(date: date.iso8601, theme: theme)
    "/?#{query}"
  end

  def position_style(start_minutes, duration_minutes)
    "left: #{start_minutes * 3}px; width: #{duration_minutes * 3}px;"
  end

  def programme_position_style(programme)
    start_minutes = programme.start_minutes
    duration_minutes = [programme.duration_minutes, (24 * 60) - start_minutes].min
    position_style(start_minutes, duration_minutes)
  end

  def programme_ended?(programme)
    @schedule_date == Date.today && programme.effective_ends_at && programme.effective_ends_at <= Time.now
  end

  def current_minutes
    return unless @schedule_date == Date.today

    Time.now.hour * 60 + Time.now.min
  end

  def current_time_style
    "left: #{current_minutes * 3}px;" if current_minutes
  end

  def timeline_time(minutes)
    Time.new(2000, 1, 1, minutes / 60, minutes % 60).strftime("%H:%M")
  end
end
