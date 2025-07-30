class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create show)
  before_action :load_user, except: %i(index new create)
  before_action :admin_user, only: %i(destroy)
  before_action :correct_user, only: %i(edit update)

  # GET /users/:id
  def show
    @page, @microposts = pagy @user.microposts, items: Settings.page_10
  end

  def index
    @pagy, @users = pagy User.newest, items: Settings.page_10
  end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t(".check_email_for_activation")
      redirect_to root_url, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id/edit
  def edit; end

  # PATCH/PUT /users/:id
  def update
    if @user.update user_params
      flash[:success] = t(".updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:success] = t(".deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to users_path
  end

  # GET /users/:id/following
  def following
    @title = t(".title")
    @pagy, @users = pagy @user.following, items: Settings.page_10
    render :show_follow
  end

  # GET /users/:id/followers
  def followers
    @title = t(".title")
    @pagy, @users = pagy @user.followers, items: Settings.page_10
    render :show_follow
  end

  private

  def correct_user
    return if current_user? @user

    flash[:error] = t(".cannot_edit")
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t(".not_admin")
    redirect_to root_path
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
