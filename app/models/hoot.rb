class Hoot < ApplicationRecord
  self.record_timestamps = false

  belongs_to :sender,     class_name: "User"
  belongs_to :receiver,   class_name: "User"
  belongs_to :friendship

  before_create { self.created_at = Time.current }

  after_create :update_streak_state
  after_create_commit :broadcast_to_receiver

  private

  def update_streak_state
    StreakService.record_hoot(friendship, sender)
  end

  def broadcast_to_receiver
    HootNotificationJob.perform_later(id)
  end
end
