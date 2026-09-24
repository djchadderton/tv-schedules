require "nokogiri"
require "open-uri"
require "time"
require "sinatra/activerecord"

require_relative "models/channel"
require_relative "models/programme"

class Schedule
  attr_reader :channels, :programmes
  URL = URI("https://raw.githubusercontent.com/dp247/Freeview-EPG/master/epg.xml").freeze

  def initialize(xml: nil)
    @xml = xml
  end

  def import!
    parsed_channels = parse_channels
    parsed_programmes = parse_programmes

    ActiveRecord::Base.transaction do
      @channels = parsed_channels.map do |attributes|
        channel = Channel.find_or_initialize_by(channel_id: attributes[:channel_id])
        channel.assign_attributes(attributes)
        channel.save!
        channel
      end

      @programmes = parsed_programmes.map do |attributes|
        programme = Programme.find_or_initialize_by(
          channel_id: attributes[:channel_id],
          starts_at: attributes[:starts_at]
        )
        programme.assign_attributes(attributes)
        programme.save!
        programme
      end

      @removed_programmes = Programme.where("ends_at < ?", Time.now.beginning_of_day).delete_all
    end

    self
  end

  def removed_programmes
    @removed_programmes || 0
  end

  def xml
    @xml ||= URI.open(URL, "User-Agent" => "Ruby XMLTV parser").read # rubocop:disable Security/Open
  end

  def doc
    @doc ||= Nokogiri::XML(xml) { |config| config.strict.nonet }
  end

  private

  def parse_channels
    doc.xpath("//channel").map do |channel|
      {
        channel_id: channel["id"],
        name: text_at(channel, "./display-name"),
        icon: channel.at_xpath("./icon")&.[]("src")
      }
    end
  end

  def parse_programmes
    doc.xpath("//programme").map do |programme|
      series, episode = /S(\d*)E(\d*)/.match(text_at(programme, "./episode-num[@system='onscreen']"))&.captures

      {
        title: text_at(programme, "./title"),
        channel_id: programme["channel"],
        icon: programme.at_xpath("./icon")&.[]("src"),
        description: text_at(programme, "./desc"),
        starts_at: parse_time(programme["start"]),
        ends_at: programme["stop"] && parse_time(programme["stop"]),
        series: series&.to_i,
        episode: episode&.to_i,
        premiere: !programme.at_xpath("./premiere").nil?
      }
    end
  end

  def text_at(node, xpath)
    node.at_xpath(xpath)&.text&.strip
  end

  def parse_time(value)
    Time.strptime(value, "%Y%m%d%H%M%S %z")
  end
end
