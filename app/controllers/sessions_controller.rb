class SessionsController < ApplicationController
  REMEMBER_ME_SELECTED = "1".freeze

  before_action :load_user, only: :create
  before_action :check_authentication, only: :create
  before_action :check_active, only: :create

  # GET /login
  def new; end

  # POST /login
  def create
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in @user
    if params.dig(:session, :remember_me) == REMEMBER_ME_SELECTED
      remember @user
    else
      remember_session @user
    end
    flash[:success] = t(".login_success")
    redirect_to forwarding_url || @user
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def load_user
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)
    return if @user

    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end

  def check_authentication
    return if @user.authenticate(params.dig(:session, :password))

    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end

  def check_active
    return if @user.activated?

    flash[:warning] = t(".account_not_activated")
    redirect_to root_url, status: :see_other
  end
end
