class WithFiscalBaseController < BaseController
  before_action :check_user_match

  private

  def check_user_match
    return if FiscalYearService.user_match?(current_fiscal_year, current_user)
    flash.now.alert = '不正なページにアクセスされました。'
    redirect_to :root
  end
end
