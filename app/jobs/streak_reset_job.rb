class StreakResetJob < ApplicationJob
  queue_as :default

  def perform
    StreakService.reset_stale_streaks!
  end
end
