class WatchUsersController < WithFiscalBaseController
  before_action :set_fiscal_year
  before_action :set_watch_users, only: [:index, :create, :edit, :update, :destroy]
  before_action :set_watch_user, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @watch_user = WatchUser.new(fiscal_year: @fiscal_year)
  end

  def edit
  end

  def create
    @watch_user = WatchUser.new(watch_user_params).tap { |m| m.fiscal_year = @fiscal_year }
    respond_to do |format|
      if @watch_user.save
        format.html { redirect_to watch_users_url, notice: '閲覧者を追加しました。' }
      else
        format.html { render :new }
        format.json { render json: @watch_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @watch_user.update(watch_user_params)
        format.html { redirect_to watch_users_url, notice: '閲覧者を更新しました。' }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @watch_user.destroy
    respond_to do |format|
      format.html { redirect_to watch_users_url, notice: 'ユーザを削除しました。' }
      format.json { head :no_content }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def set_watch_users
    @watch_users = @fiscal_year.watch_users
  end

  def set_watch_user
    @watch_user = WatchUser.find(params[:id])
  end

  def watch_user_params
    params.require(:watch_user).permit(:fiscal_year, :user_email, :user_id, :can_modify)
  end
end
