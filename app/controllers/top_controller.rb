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
    return if @no_years

    # 会計年度がある場合は、セッションに初期値を設定
    session[:fiscal_year_id] ||= session[:fiscal_year_id] || @fiscal_years.first.id
    session[:journal_date] ||= Date.today

    # 会計年度がある場合は、ダッシュボードの内容を設定
    @fiscal_year = @fiscal_years.find { |m| m.id == session[:fiscal_year_id].to_i }
    @journal_date = session[:journal_date].to_date
    # TODO: 実装
  end
end
