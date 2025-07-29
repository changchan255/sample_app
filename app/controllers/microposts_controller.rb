class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: %i(destroy)

  def index
    @microposts = Micropost.recent
  end

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params.dig(:micropost, :image)
    if @micropost.save
      flash[:success] = t(".created")
      redirect_to root_url
    else
      @pagy, @feed_items = pagy current_user.feed, items: Settings.page_10
      render "static_pages/home", status: :unprocessable_entity
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t(".deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(Micropost::MICROPOST_PERMITTED)
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t(".invalid")
    redirect_to request.referer || root_url
  end
end
