class FiscalYearsCopyController < BaseController
  def new
    @fiscal_year = FiscalYear.find(params[:id]).dup.tap { |m|
      m.title = m.title + ' - コピー'
      m.date_from = m.date_from.next_year
      m.date_to = m.date_to.next_year
      m.locked = false
    }
  end

  def create
    base_fiscal_year = FiscalYear.find(params[:id])
    @fiscal_year = base_fiscal_year.dup
    @fiscal_year.update(fiscal_year_params)

    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @fiscal_year.save
          # 科目(Subject)を、コピー元の会計年度分より生成
          FiscalYearService.subjects_from_base_fiscal_year(base_fiscal_year, @fiscal_year).each(&:save)
          format.html { redirect_to fiscal_years_url, notice: '会計年度を複製しました。' }
          format.json { render :index, status: :created, location: @fiscal_years }
        else
          format.html { render :new }
          format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def fiscal_year_params
    params.
      require(:fiscal_year).
      permit(
        :user_id, :account_type_id, :subject_template_type_id, :title, :organization_name,
        :date_from, :date_to, :locked)
  end
end
