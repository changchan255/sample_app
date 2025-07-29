class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(edit update)
  before_action :load_user_by_email, only: %i(create)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)
  before_action :check_empty_password, only: %i(update)

  # GET /password_resets/new
  def new; end

  # POST /password_resets
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".email_sent")
    redirect_to root_url
  end

  # GET /password_resets/:id/edit
  def edit; end

  # PATCH /password_resets/:id
  def update
    if @user.update user_params
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t(".password_reset_success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(User::PASSWORD_RESET_PERMITTED)
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t(".not_found")
    redirect_to root_url
  end

  def load_user_by_email
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    return if @user

    flash.now[:danger] = t(".email_not_found")
    render :new, status: :unprocessable_entity
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".inactivated")
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_url
  end

  def check_empty_password
    return unless user_params[:password].empty?

    @user.errors.add :password, t(".error")
    render :edit, status: :unprocessable_entity
  end
end
