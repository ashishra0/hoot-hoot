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

  def owl_status_message(mood, partner_name)
    case mood
    when :happy
      [ "You both hooted today!", "Streak secured! Hoot some more?", "Hoot hoot! All good today." ].sample
    when :waiting
      [ "Waiting on #{partner_name}...", "#{partner_name} hasn't hooted yet...", "I'm waiting..." ].sample
    when :excited
      [ "#{partner_name} hooted you!", "Hoot back! Don't leave them hanging!", "Your turn! Tap me!" ].sample
    when :celebrating
      [ "Streak milestone!", "You two are on fire!", "Look at that streak go!" ].sample
    when :sleepy
      [ "Tap me to send a hoot!", "Nobody's hooted yet today...", "Hoot hoot?" ].sample
    else
      "Tap the owl to hoot!"
    end
  end
end
