class DashboardController < ApplicationController
  before_action :require_authentication

  def show
    @friendships = current_user.friendships.includes(:user, :friend).order(current_streak: :desc)
    @friendships.each { |f| StreakService.refresh!(f) }
  end
end
