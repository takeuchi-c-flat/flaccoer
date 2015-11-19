class TopController < BaseController
  # TOP画面は、事前認証はSKIPします。
  skip_before_action :authorize

  def index
    unless current_user
      redirect_to :login
      return
    end

    @fiscal_years = FiscalYearService.accessible_fiscal_years(current_user)
    @no_years = @fiscal_years.empty?
    @user = current_user
    return if @no_years

    # 会計年度がある場合は、セッションに初期値を設定
    if session[:fiscal_year_id].nil?
      today = Date.today
      default_fiscal_year = FiscalYearService.get_default_fiscal_year(today, @fiscal_years, current_user)
      session[:fiscal_year_id] = default_fiscal_year.id
      session[:journal_date] = FiscalYearService.adjust_journal_date(today, default_fiscal_year)
    end

    # 会計年度がある場合は、ダッシュボードの内容を設定
    @fiscal_year = @fiscal_years.find { |m| m.id == session[:fiscal_year_id].to_i }
    @journal_date = session[:journal_date].to_date
    @dashboards1 = DashboardService.create_dashboard_data_debit_and_credit(@fiscal_year, @journal_date)
    @dashboards2 = DashboardService.create_dashboard_data_profit_and_loss(@fiscal_year, @journal_date)
  end
end
