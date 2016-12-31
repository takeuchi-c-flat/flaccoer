class FiscalYearsController < BaseController
  before_action :set_fiscal_year, only: [:copy, :edit, :update, :destroy]
  before_action :set_tab_types, only: [:new, :edit, :copy, :carry]

  def index
    @fiscal_years = FiscalYear.where(user: current_user)
  end

  def new
    @fiscal_year = FiscalYear.new.tap { |m|
      m.user = current_user
      m.base_fiscal_year_id = 0
      m.for_copy = false
    }
  end

  def copy
    copy_or_carry(false)
  end

  def carry
    copy_or_carry(true)
  end

  def edit
  end

  def create
    strong_params = fiscal_year_params
    base_fiscal_year_id = strong_params[:base_fiscal_year_id].to_i
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if strong_params[:for_copy] == 'true'
          # 科目(Subject)を、コピー／繰越元の科目より生成
          base_fiscal_year = FiscalYear.find(base_fiscal_year_id)
          with_carry = strong_params[:with_carry]
          @fiscal_year = base_fiscal_year.dup
          @fiscal_year.update(strong_params)
          FiscalYearService.create_subjects_from_base_fiscal_year(base_fiscal_year, @fiscal_year, with_carry)
        else
          # 科目(Subject)を、科目テンプレートより生成
          @fiscal_year = FiscalYear.new(strong_params).tap { |m| m.user = current_user }
          FiscalYearService.create_subjects_from_template(@fiscal_year.subject_template_type, @fiscal_year)
        end

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
      respond_to do |format|
        format.html { redirect_to fiscal_years_url, alert: '保守画面から、取引明細・残高・予算を削除してください。' }
      end
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

  def set_tab_types
    @tab_types = FiscalYearService.get_tab_types()
  end

  def fiscal_year_params
    params.
      require(:fiscal_year).
      permit(
        :user_id, :account_type_id, :subject_template_type_id, :title, :organization_name,
        :date_from, :date_to, :locked, :tab_type, :list_desc,
        :for_copy, :with_carry, :base_fiscal_year_id)
  end

  def copy_or_carry(with_carry)
    @fiscal_year = FiscalYear.find(params[:id]).dup.tap { |m|
      m.title += '- コピー' unless with_carry
      m.date_from = m.date_from.next_year
      m.date_to = m.date_to.next_year
      m.locked = false,
      m.for_copy = true,
      m.with_carry = with_carry,
      m.base_fiscal_year_id = params[:id]
    }
  end
end
