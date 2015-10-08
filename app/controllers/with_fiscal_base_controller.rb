class WithFiscalBaseController < BaseController
  before_action :check_user_match

  private

  def check_user_match
    fiscal_year = current_fiscal_year
    return if fiscal_year.present? && fiscal_year.user == current_user

    flash.now.alert = '不正なページにアクセスされました。'
    redirect_to :root
  end
end
