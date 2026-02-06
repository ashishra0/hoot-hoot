module StreakHelper
  STREAK_EMOJIS = {
    cold: "\u2744\uFE0F",       # snowflake
    fire: "\u{1F525}",          # fire
    star: "\u2B50",             # star
    diamond: "\u{1F48E}"        # diamond
  }.freeze

  def streak_emoji(count)
    case count
    when 0       then STREAK_EMOJIS[:cold]
    when 1..6    then STREAK_EMOJIS[:fire]
    when 7..29   then "#{STREAK_EMOJIS[:fire]}#{STREAK_EMOJIS[:fire]}"
    when 30..99  then STREAK_EMOJIS[:star]
    else              STREAK_EMOJIS[:diamond]
    end
  end

  def streak_status_text(friendship, user)
    i_hooted = friendship.hooted_today?(user)
    they_hooted = friendship.hooted_today?(friendship.partner_of(user))

    if i_hooted && they_hooted
      "Both hooted today! Streak secured."
    elsif i_hooted
      "You hooted! Waiting on them..."
    elsif they_hooted
      "They hooted you! Hoot back!"
    else
      "Neither has hooted today."
    end
  end
end
