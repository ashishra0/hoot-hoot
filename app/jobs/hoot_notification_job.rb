class HootNotificationJob < ApplicationJob
  queue_as :default

  def perform(hoot_id)
    hoot = Hoot.find_by(id: hoot_id)
    return unless hoot

    # Broadcast toast notification to receiver
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{hoot.receiver_id}_hoots",
      target: "hoot-notifications",
      partial: "hoots/notification",
      locals: { hoot: hoot }
    )

    # Update the friendship card for the receiver
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{hoot.receiver_id}_hoots",
      target: "friendship_#{hoot.friendship_id}",
      partial: "friendships/card",
      locals: { friendship: hoot.friendship, current_user: hoot.receiver }
    )
  end
end
