class Programme < ActiveRecord::Base
  belongs_to :channel, foreign_key: "channel_id", primary_key: "channel_id"

  def channel_name
    @channel_name ||= channel&.name
  end

  def duration_minutes
    @duration_minutes ||= ((ends_at - starts_at) / 60).to_i
  end
end
