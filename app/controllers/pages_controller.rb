class PagesController < ApplicationController
  def landing
    redirect_to dashboard_path if current_user
  end
end
