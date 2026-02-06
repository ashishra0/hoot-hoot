class RegistrationsController < ApplicationController
  def new
    redirect_to dashboard_path if current_user
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      session[:user_id] = @user.id
      if (invite_token = session.delete(:pending_invite_token))
        redirect_to claim_invite_path(token: invite_token)
      else
        redirect_to dashboard_path, notice: "Welcome to HootHoot!"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :display_name)
  end
end
