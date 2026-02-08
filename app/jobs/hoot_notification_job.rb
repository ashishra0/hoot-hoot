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

    stream_name = "user_#{receiver.id}_hoots"

    # Toast notification -- always shown regardless of which friend is being viewed
    Turbo::StreamsChannel.broadcast_append_to(
      stream_name,
      target: "hoot-notifications",
      partial: "hoots/notification",
      locals: { hoot: hoot }
    )

    # Dashboard updates -- only applied if the receiver is currently viewing THIS friendship
    broadcast_replace_if_active(
      stream_name, friendship,
      "streak-display", "dashboard/streak_display",
      { friendship: friendship }
    )

    broadcast_replace_if_active(
      stream_name, friendship,
      "status-text", "dashboard/status_text",
      { owl_mood: owl_mood, partner: sender }
    )

    broadcast_replace_if_active(
      stream_name, friendship,
      "owl-area", "dashboard/owl_area",
      { owl_mood: owl_mood }
    )
  end

  private

  def broadcast_replace_if_active(stream_name, friendship, target, partial, locals)
    html = ApplicationController.render(partial: partial, locals: locals)

    Turbo::StreamsChannel.broadcast_stream_to(
      stream_name,
      content: <<~TURBO_STREAM
        <turbo-stream action="replace_if_active" target="#{target}" friendship-id="#{friendship.id}">
          <template>#{html}</template>
        </turbo-stream>
      TURBO_STREAM
    )
  end

  def compute_mood(friendship, i_hooted, they_hooted)
    return :celebrating if friendship.current_streak > 0 && [ 7, 14, 30, 50, 69, 100, 200, 365 ].include?(friendship.current_streak)
    return :happy       if i_hooted && they_hooted
    return :excited     if !i_hooted && they_hooted
    return :waiting     if i_hooted && !they_hooted
    :sleepy
  end
end
