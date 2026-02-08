class DashboardController < ApplicationController
  before_action :require_authentication

  def show
    @friendships = current_user.friendships.includes(:user, :friend).order(updated_at: :desc)

    @friendship = if params[:friendship_id].present?
                    @friendships.find_by(id: params[:friendship_id])
                  end
    @friendship ||= @friendships.first

    if @friendship
      StreakService.refresh!(@friendship)
      @partner = @friendship.partner_of(current_user)
      @i_hooted = @friendship.hooted_today?(current_user)
      @they_hooted = @friendship.hooted_today?(@partner)
      @owl_mood = determine_mood
    end
  end

  private

  def determine_mood
    return :celebrating if @friendship.current_streak > 0 && milestone?(@friendship.current_streak)
    return :happy       if @i_hooted && @they_hooted
    return :waiting     if @i_hooted && !@they_hooted
    return :excited     if !@i_hooted && @they_hooted
    :sleepy
  end

  def milestone?(streak)
    [ 7, 14, 30, 50, 69, 100, 200, 365 ].include?(streak)
  end
end
