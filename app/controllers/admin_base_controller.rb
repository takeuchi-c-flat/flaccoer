class AdminBaseController < BaseController
  before_action :check_admin_user

  private

  def check_admin_user
    if current_user && !current_user.admin_user?
      session.delete(:user_id)
      flash.alert = 'この画面には管理者権限が必要です。'
      redirect_to :login
    end
  end
end
