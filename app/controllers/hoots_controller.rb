class HootsController < ApplicationController
  before_action :require_authentication

  def create
    @friendship = Friendship
      .where(id: params[:friendship_id])
      .where("user_id = ? OR friend_id = ?", current_user.id, current_user.id)
      .first!

    receiver = @friendship.partner_of(current_user)

    @hoot = Hoot.create!(
      sender: current_user,
      receiver: receiver,
      friendship: @friendship
    )

    @friendship.reload
    @partner = receiver
    @i_hooted = @friendship.hooted_today?(current_user)
    @they_hooted = @friendship.hooted_today?(@partner)
    @owl_mood = determine_mood

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_path }
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
