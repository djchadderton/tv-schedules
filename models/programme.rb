class Programme < ActiveRecord::Base
  belongs_to :channel, foreign_key: "channel_id", primary_key: "channel_id"

  def channel_name
    @channel_name ||= channel&.name
  end

  def start_minutes = starts_at.hour * 60 + starts_at.min

  def end_minutes = ends_at.hour * 60 + ends_at.min

  def duration_minutes
    (end_minutes > start_minutes) ? end_minutes - start_minutes : (24 * 60 - start_minutes) + end_minutes
  end
end
