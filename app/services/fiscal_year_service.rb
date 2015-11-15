module FiscalYearService
  module_function

  MAX_MONTHS_COUNT = 18

  # Userがアクセス可能な会計年度を取得します。
  def accessible_fiscal_years(user)
    my_fiscal_years(user) + permitted_fiscal_years(user)
  end

  # Userの所有する会計年度を取得します。
  def my_fiscal_years(user)
    FiscalYear.where(user: user).order(date_from: :desc)
  end

  # Userがアクセスを許可された会計年度を取得します。
  def permitted_fiscal_years(_user)
    # TODO: 実装(要TABLE追加)
    FiscalYear.where(user_id: -1).order(date_from: :desc)
  end

  # 月数が制限値以内かを確認します。
  def validate_months_range(date_from, date_to)
    DateService.months_count_from_date_span(date_from, date_to) <= MAX_MONTHS_COUNT
  end

  # 取引日付を確認します。
  def validate_journal_date(fiscal_year, date)
    return false if date.nil?
    fiscal_year.date_from <= date && date <= fiscal_year.date_to
  end

  # 新しい会計年度用の科目一覧を、科目テンプレートから生成します。
  def subjects_from_template(subject_template_type, new_fiscal_year)
    templates = SubjectTemplate.where(subject_template_type: subject_template_type)
    templates.map { |template|
      Subject.new.tap { |m|
        m.fiscal_year = new_fiscal_year
        m.subject_type = template.subject_type
        m.code = template.code
        m.name = template.name
        m.set_report_locations(template.get_report_locations)
        m.from_template = true
      }
    }
  end

  # 新しい会計年度用の科目一覧を、コピー元の会計年度の科目から生成します。
  def subjects_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
    subjects = Subject.where(fiscal_year: base_fiscal_year).map { |m| m.dup }
    subjects.each { |m| m.fiscal_year = new_fiscal_year}
    subjects
  end

  # 会計年度分の取引明細・残高・予算を取得して、削除が可能かをチェックします。
  def fiscal_year_can_delete?(fiscal_year)
    Journal.find_by(fiscal_year: fiscal_year).nil? &&
      Balance.find_by(fiscal_year: fiscal_year).nil? &&
      Badget.find_by(fiscal_year: fiscal_year).nil?
  end

  # 会計年度分の科目一覧を取得します。(削除用です)
  def get_subjects_by_fiscal_year(fiscal_year)
    Subject.where(fiscal_year: fiscal_year).to_a
  end

  # 会計年度の初期値の候補を取得します。
  def get_default_fiscal_year(date, fiscal_years, user)
    default = fiscal_years.find { |m| m.date_from <= date && date <= m.date_to && !m.locked? && m.user == user }
    return default if default.present?
    fiscal_years.first
  end

  # 会計年度の期間を元に、取引日の初期値を調整します。
  def adjust_journal_date(journal_date, fiscal_year)
    return Date.today if fiscal_year.nil?
    return fiscal_year.date_from if journal_date < fiscal_year.date_from
    return fiscal_year.date_to if fiscal_year.date_to < journal_date
    journal_date
  end
end
