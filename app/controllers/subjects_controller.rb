class SubjectsController < WithFiscalBaseController
  before_action :set_fiscal_year, only: [:edit_all, :update_all]
  before_action :set_subject_types, only: [:new, :create]

  def edit_all
  end

  def update_all
    respond_to do |format|
      @fiscal_year.update(fiscal_year_params)
      SubjectsService.cleanup_subjects(@fiscal_year)
      SubjectsCacheService.clear_subjects_cache(@fiscal_year)
      format.html { redirect_to subjects_url, notice: '勘定科目を更新しました。(バックアップをしましょう)' }
      format.json { render :index, location: @subjects }
    end
  end

  def new
    # TODO: UT
    @subject = Subject.new.tap { |m| m.fiscal_year = current_fiscal_year }
  end

  def create
    respond_to do |format|
      @subject = Subject.new(subject_params).tap { |m| m.fiscal_year = current_fiscal_year }
      SubjectsCacheService.clear_subjects_cache(@subject.fiscal_year)
      if @subject.save
        format.html { redirect_to subjects_url, notice: '勘定科目を追加しました。(バックアップをしましょう)' }
        format.json { render :index, status: :created, location: @subjects }
      else
        format.html { render :new }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subject = Subject.find(params[:id])
    unless SubjectsService.subject_can_delete?(current_fiscal_year, @subject)
      flash.now.alert = '取引明細が存在する勘定科目は削除できません。'
      return
    end

    @subject.destroy
    SubjectsService.cleanup_subjects(@subject.fiscal_year)
    SubjectsCacheService.clear_subjects_cache(@subject.fiscal_year)
    respond_to do |format|
      format.html { redirect_to subjects_url, notice: '勘定科目を削除しました。(バックアップをしましょう)' }
      format.json { head :no_content }
    end
  end

  private

  def set_fiscal_year
    @fiscal_year = current_fiscal_year
  end

  def set_subject_types
    @subject_types = SubjectType.where(account_type: current_fiscal_year.account_type)
  end

  def fiscal_year_params
    params.require(:fiscal_year).permit(
      :id,
      subjects_attributes: [
        :id, :code, :name,
        :report1_location, :report2_location, :report3_location, :report4_location, :report5_location,
        :disabled, :dash_board])
  end

  def subject_params
    params.require(:subject).permit(:subject_type_id, :code, :name)
  end
end
