class Programme < ActiveRecord::Base
  belongs_to :channel, foreign_key: "channel_id", primary_key: "channel_id"

  def channel_name
    @channel_name ||= channel&.name
  end

  def local_starts_at = starts_at&.getlocal

  def local_ends_at = ends_at&.getlocal

  def start_minutes = local_starts_at.hour * 60 + local_starts_at.min

  def end_minutes = local_ends_at.hour * 60 + local_ends_at.min

  def duration_minutes
    return 0 unless ends_at

    (end_minutes > start_minutes) ? end_minutes - start_minutes : (24 * 60 - start_minutes) + end_minutes
  end

  def effective_ends_at
    return unless local_ends_at

    (local_ends_at < local_starts_at) ? local_ends_at + 24.hours : local_ends_at
  end
end
