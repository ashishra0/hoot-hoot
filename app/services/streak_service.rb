class StreakService
  # Called inside the Hoot creation transaction
  def self.record_hoot(friendship, sender)
    today = Date.current

    # If streak_date is stale (missed a full day), reset streak
    if friendship.streak_date.present? && friendship.streak_date < today - 1
      friendship.current_streak = 0
      friendship.user_hooted_today = false
      friendship.friend_hooted_today = false
      friendship.streak_date = nil
    elsif friendship.streak_date.present? && friendship.streak_date < today
      # New day but streak is alive: reset today's flags
      friendship.user_hooted_today = false
      friendship.friend_hooted_today = false
    end

    # Mark this sender's side
    role = friendship.role_of(sender)
    if role == :user
      friendship.user_hooted_today = true
    else
      friendship.friend_hooted_today = true
    end

    # Check if both have hooted today
    if friendship.user_hooted_today && friendship.friend_hooted_today
      # Only increment if we haven't already for today
      if friendship.streak_date != today
        friendship.current_streak += 1
        friendship.longest_streak = [ friendship.longest_streak, friendship.current_streak ].max
        friendship.streak_date = today
      end
    end

    friendship.save!
  end

  # Called on dashboard load to ensure fresh data
  def self.refresh!(friendship)
    today = Date.current

    if friendship.streak_date.present? && friendship.streak_date < today - 1
      # Missed a full day: reset streak
      friendship.update!(
        current_streak: 0,
        user_hooted_today: false,
        friend_hooted_today: false,
        streak_date: nil
      )
    elsif friendship.streak_date.present? && friendship.streak_date < today
      # New day, streak alive: reset today's flags
      friendship.update!(
        user_hooted_today: false,
        friend_hooted_today: false
      )
    end
    # If streak_date == today, do nothing (already current)
  end

  # Called by nightly job
  def self.reset_stale_streaks!
    yesterday = Date.current - 1
    Friendship.where.not(current_streak: 0)
              .where("streak_date < ? OR streak_date IS NULL", yesterday)
              .update_all(
                current_streak: 0,
                user_hooted_today: false,
                friend_hooted_today: false,
                streak_date: nil
              )
  end
end
