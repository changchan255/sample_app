class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :admin_user, only: %i(destroy)
  before_action :correct_user, only: %i(edit update)

  # GET /users/:id
  def show; end

  def index
    @pagy, @users = pagy User.all_users, items: Settings.page_10
  end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      reset_session
      log_in @user
      flash[:success] = t(".created")
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t(".updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t(".deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to users_path
  end

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t(".please_log_in")
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t(".cannot_edit")
    redirect_to root_url
  end

  def admin_user
    redirect_to_root_path unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t(".not_found")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(User::USER_PERMITTED)
  end
end
