class HootNotificationJob < ApplicationJob
  queue_as :default

  def perform(hoot_id)
    hoot = Hoot.find_by(id: hoot_id)
    return unless hoot

    friendship = hoot.friendship
    receiver = hoot.receiver
    sender = hoot.sender

    i_hooted = friendship.hooted_today?(receiver)
    they_hooted = friendship.hooted_today?(sender)
    owl_mood = compute_mood(friendship, i_hooted, they_hooted)
    partner_name = sender.display_name || sender.username

    # Toast notification
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{receiver.id}_hoots",
      target: "hoot-notifications",
      partial: "hoots/notification",
      locals: { hoot: hoot }
    )

    # Update streak display
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{receiver.id}_hoots",
      target: "streak-display",
      partial: "dashboard/streak_display",
      locals: { friendship: friendship }
    )

    # Update status text
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{receiver.id}_hoots",
      target: "status-text",
      partial: "dashboard/status_text",
      locals: { owl_mood: owl_mood, partner: sender }
    )

    # Update owl mood
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{receiver.id}_hoots",
      target: "owl-area",
      partial: "dashboard/owl_area",
      locals: { owl_mood: owl_mood }
    )
  end

  private

  def compute_mood(friendship, i_hooted, they_hooted)
    return :celebrating if friendship.current_streak > 0 && [ 7, 14, 30, 50, 69, 100, 200, 365 ].include?(friendship.current_streak)
    return :happy       if i_hooted && they_hooted
    return :excited     if !i_hooted && they_hooted
    return :waiting     if i_hooted && !they_hooted
    :sleepy
  end
end
