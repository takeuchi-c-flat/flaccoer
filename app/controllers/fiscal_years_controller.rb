class FiscalYearsController < BaseController
  before_action :set_fiscal_year, only: [:edit, :update, :destroy]

  def index
    @fiscal_years = FiscalYear.where(user: current_user)
  end

  def new
    @fiscal_year = FiscalYear.new.tap { |m| m.user = current_user }
  end

  def edit
  end

  def create
    @fiscal_year = FiscalYear.new(fiscal_year_params).tap { |m| m.user = current_user }
    ActiveRecord::Base.transaction do
      respond_to do |format|
        # 科目(Subject)を、科目テンプレートより生成
        FiscalYearService.subjects_from_template(@fiscal_year.subject_template_type, @fiscal_year).each(&:save)
        if @fiscal_year.save
          format.html { redirect_to fiscal_years_url, notice: '会計年度を登録しました。' }
          format.json { render :index, status: :created, location: @fiscal_years }
        else
          format.html { render :new }
          format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @fiscal_year.update(fiscal_year_params)
          format.html { redirect_to fiscal_years_url, notice: '会計年度を更新しました。' }
          format.json { render :index, status: :ok, location: @fiscal_years }
        else
          format.html { render :edit }
          format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    # 取引明細の存在をチェック
    unless FiscalYearService.fiscal_year_can_delete?(@fiscal_year)
      flash.now.alert = '保守画面から、取引明細・残高・予算を削除してください。'
      return
    end

    ActiveRecord::Base.transaction do
      # 科目(Subject)を削除
      FiscalYearService.get_subjects_by_fiscal_year(@fiscal_year).each(&:destroy)
      # 会計年度を削除
      @fiscal_year.destroy
      respond_to do |format|
        format.html { redirect_to fiscal_years_url, notice: '会計年度を削除しました。' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = FiscalYear.find(params[:id])
  end

  def fiscal_year_params
    params.
      require(:fiscal_year).
      permit(
        :user_id, :account_type_id, :subject_template_type_id, :title, :organization_name,
        :date_from, :date_to, :locked)
  end
end