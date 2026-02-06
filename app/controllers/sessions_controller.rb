class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if current_user
  end

  def create
    user = User.authenticate_by(
      email: params[:email].to_s.strip.downcase,
      password: params[:password]
    )

    if user
      session[:user_id] = user.id
      if (invite_token = session.delete(:pending_invite_token))
        redirect_to claim_invite_path(token: invite_token)
      elsif (return_to = session.delete(:return_to))
        redirect_to return_to, notice: "Welcome back!"
      else
        redirect_to dashboard_path, notice: "Welcome back!"
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Logged out successfully."
  end
end
