class FriendshipsController < ApplicationController
  before_action :require_authentication

  def index
    @friendships = current_user.friendships.includes(:user, :friend).order(updated_at: :desc)
    @friendships.each { |fs| StreakService.refresh!(fs) }
  end

  def destroy
    @friendship = Friendship
      .where(id: params[:id])
      .where("user_id = ? OR friend_id = ?", current_user.id, current_user.id)
      .first!

    @friendship.destroy!
    redirect_to dashboard_path, notice: "Friend removed."
  end
end
