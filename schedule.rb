require "nokogiri"
require "open-uri"
require "time"
require "sinatra/activerecord"

require_relative "models/channel"
require_relative "models/programme"

class Schedule
  attr_reader :channels, :programmes
  URL = URI("https://raw.githubusercontent.com/dp247/Freeview-EPG/master/epg.xml").freeze

  def initialize
    load_channels
    load_programmes
  end

  def xml
    @xml ||= URI.open(URL, "User-Agent" => "Ruby XMLTV parser").read # rubocop:disable Security/Open
  end

  def doc
    @doc ||= Nokogiri::XML(xml) { |config| config.strict.nonet }
  end

  def load_channels
    @channels = []
    doc.xpath("//channel").each do |channel|
      Channel.find_or_create_by(channel_id: channel["id"]) do |c|
        c.name = channel.at_xpath("./display-name")&.text&.strip
        c.icon = channel.at_xpath("./icon")&.[]("src")
      end
    end
  end

  def load_programmes
    @programmes = []

    doc.xpath("//programme").each do |programme|
      series, episode = /S(\d*)E(\d*)/.match(programme.at_xpath("./episode-num[@system='onscreen']"))&.captures

      Programme.find_or_create_by(title: programme.at_xpath("./title")&.text&.strip, channel_id: programme["channel"], starts_at: programme["start"]) do |p|
        p.icon = programme.at_xpath("./icon")&.[]("src")
        p.description = programme.at_xpath("./desc")&.text&.strip
        p.starts_at = Time.strptime(programme["start"], "%Y%m%d%H%M%S %z")
        p.ends_at = programme["stop"] && Time.strptime(programme["stop"], "%Y%m%d%H%M%S %z")
        p.series = series&.to_i
        p.episode = episode&.to_i
        p.premiere = programme.at_xpath("./premiere")
      end
    end
  end
end
