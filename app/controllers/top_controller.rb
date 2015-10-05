class TopController < BaseController
  # TOP画面は、事前認証はSKIPします。
  skip_before_action :authorize

  def index
    unless current_user
      redirect_to :login
      return
    end

    @fiscal_years = FiscalYear.where(user: current_user).order(date_from: :desc).to_a
    @no_years = @fiscal_years.empty?
    unless @no_years
      @top_form = TopForm.new
      @top_form.fiscal_year_id = session[:fiscal_year_id] || @fiscal_years.first.id
      @top_form.journal_date = session[:journal_date].present? ? session[:journal_date].to_date : Date.today
      session[:fiscal_year_id] = @top_form.fiscal_year_id
      session[:journal_date] = @top_form.journal_date.to_s
    end
    render action: 'index'
  end

  # POST 'top'
  def start
    @top_form = TopForm.new(params[:top_form])
    set_session_by_top_form(top_form_params)

    # TODO: 記帳の画面に変更
    redirect_to :root
  end

  private

  def set_session_by_top_form(form)
    fiscal_year = FiscalYear.find_by(id: form[:fiscal_year_id])
    session[:fiscal_year_id] = fiscal_year.nil? ? nil : fiscal_year.id.to_s
    session[:journal_date] = FiscalYearService.adjust_journal_date(form[:journal_date].to_date, fiscal_year).to_s
  end

  def top_form_params
    params.require(:top_form).permit(:fiscal_year_id, :journal_date)
  end
end
