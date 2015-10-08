class BaseController < ApplicationController
  before_action :authorize
  before_action :check_account
  before_action :check_timeout

  private

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def current_fiscal_year
    if session[:fiscal_year_id]
      @current_fiscal_year = FiscalYear.find_by(id: session[:fiscal_year_id])
    end
  end

  def authorize
    unless current_user
      flash.alert = 'ログインしてください。'
      redirect_to :login
    end
  end

  def check_account
    if current_user && current_user.suspended?
      session.delete(:user_id)
      flash.alert = 'アカウントが無効になりました。'
      redirect_to :login
    end
  end

  TIMEOUT = 60.minutes

  def check_timeout
    return unless current_user
    if session[:last_access_time] >= TIMEOUT.ago
      session[:last_access_time] = Time.current
    else
      session.delete(:user_id)
      flash.alert = 'セッションがタイムアウトしました。'
      redirect_to :login
    end
  end

  helper_method :current_user, :current_fiscal_year
end
