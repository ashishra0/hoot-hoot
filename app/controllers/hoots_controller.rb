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

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_path }
    end
  end
end
