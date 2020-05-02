class JournalsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:list, :new, :copy, :create, :edit, :update, :set_mark, :reset_mark]
  before_action :set_journal, only: [:copy, :edit, :update, :destroy]
  before_action :set_subjects, only: [:new, :copy, :create, :edit, :update]
  before_action :create_tabs, only: [:new, :copy, :create, :edit, :update]

  def subjects_debit
    @subjects = SubjectsCacheService.get_subject_list_with_usage_ranking(current_fiscal_year, true)
    @td_class_name = 'select-subject-debit'
    render 'subjects', layout: false
  end

  def subjects_credit
    @subjects = SubjectsCacheService.get_subject_list_with_usage_ranking(current_fiscal_year, false)
    @td_class_name = 'select-subject-credit'
    render 'subjects', layout: false
  end

  def list
    tab_name = params[:id]
    @journals = JournalsService.journal_list_from_tab_name(tab_name, current_fiscal_year)
    render 'list', layout: false
  end

  def new
    @new = true
    @journal = Journal.new.tap { |m|
      m.fiscal_year = current_fiscal_year
      m.journal_date = session[:journal_date].to_date
    }
  end

  def copy
    @journal = @journal.dup.tap { |m|
      m.journal_date = session[:journal_date].to_date
    }
  end

  def edit
  end

  def create
    @journal = Journal.new(journal_params).tap { |m| m.fiscal_year = @fiscal_year }
    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_url, notice: '取引明細を登録しました。' }
        format.json { render :new, status: :created, location: @journals }
      else
        format.html { render :new }
        format.json { render json: @journals.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @journal.update(journal_params)
        format.html { redirect_to journals_url, notice: '会計年度を更新しました。' }
        format.json { render :index, status: :ok, location: @journals }
      else
        format.html { render :edit }
        format.json { render json: @fiscal_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @journal.destroy
    respond_to do |format|
      format.html { redirect_to journals_url, notice: '取引明細を削除しました。' }
      format.json { head :no_content }
    end
  end

  def set_mark
    update_mark(params[:id], true)
    render body: nil
  end

  def reset_mark
    update_mark(params[:id], false)
    render body: nil
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
    @journal_date = session[:journal_date].to_date
    @can_modify = current_fiscal_year.can_modify?(current_user)
  end

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def set_subjects
    @subjects = SubjectsCacheService.get_subject_list(current_fiscal_year)
  end

  def journal_params
    params.require(:journal).permit(:journal_date, :subject_debit_id, :subject_credit_id, :price, :comment)
  end

  def create_tabs
    @journal_months = JournalsService.create_journal_months(@fiscal_year, @journal_date)
  end

  def update_mark(id, set)
    journal = Journal.find_by(id: id)
    return if journal.nil? || journal.fiscal_year != @fiscal_year
    journal.mark = set
    journal.save
  end
end
