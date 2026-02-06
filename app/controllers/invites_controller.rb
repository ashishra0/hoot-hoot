class InvitesController < ApplicationController
  before_action :require_authentication, only: [ :create, :index ]

  def index
    @invites = current_user.invites.order(created_at: :desc)
  end

  def create
    @invite = current_user.invites.create!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to invites_path }
    end
  end

  def show
    @invite = Invite.find_by!(token: params[:token])

    if @invite.expired?
      render :expired and return
    end

    if @invite.claimed?
      redirect_to(current_user ? dashboard_path : login_path, notice: "This invite has already been used.") and return
    end

    unless current_user
      session[:pending_invite_token] = params[:token]
      redirect_to login_path, notice: "Log in or sign up to accept this invite!" and return
    end

    if current_user.id == @invite.user_id
      redirect_to dashboard_path, alert: "That's your own invite link!" and return
    end

    @inviter = @invite.user
    @already_friends = Friendship.between(current_user, @inviter).present?
  end

  def claim
    @invite = Invite.find_by!(token: params[:token])
    return redirect_to(login_path) unless current_user
    return redirect_to(dashboard_path, alert: "This invite has expired.") if @invite.expired?
    return redirect_to(dashboard_path, alert: "This invite has already been used.") if @invite.claimed?
    return redirect_to(dashboard_path, notice: "You're already friends!") if Friendship.between(current_user, @invite.user)
    return redirect_to(dashboard_path, alert: "You can't accept your own invite!") if current_user.id == @invite.user_id

    ActiveRecord::Base.transaction do
      Friendship.create!(user: current_user, friend: @invite.user)
      @invite.update!(claimed_by: current_user, claimed_at: Time.current)
    end

    redirect_to dashboard_path, notice: "You and @#{@invite.user.username} are now friends!"
  end
end
