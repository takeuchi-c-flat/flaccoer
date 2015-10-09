class BadgetsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:edit, :update]

  def edit
    # 存在しないレコードは、先に作ってしまう。
    BadgetService.pre_create_badgets(@fiscal_year)
  end

  def update
    respond_to do |format|
      @fiscal_year.update(fiscal_year_params)
      format.html { redirect_to root_url, notice: '年間予算を更新しました。' }
      format.json { render :index, location: @root }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def fiscal_year_params
    params.require(:fiscal_year).permit(
      :id,
      subjects_attributes: [:id],
      profit_badgets_attributes: [:id, :subject_id, :total_badget],
      loss_badgets_attributes: [:id, :subject_id, :total_badget])
  end
end
