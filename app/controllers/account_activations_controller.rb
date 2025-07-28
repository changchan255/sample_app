class AccountActivationsController < ApplicationController
  before_action :load_user, only: %i(edit)
  before_action :check_authentication, only: %i(edit)

  # GET /account_activations/:id/edit
  def edit
    @user.activate
    log_in @user
    flash[:success] = t(".account_activated")
    redirect_to @user
  end

  private

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_url
  end

  def check_authentication
    return if !@user.activated && @user.authenticated?(:activation, params[:id])

    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_url
  end
end
