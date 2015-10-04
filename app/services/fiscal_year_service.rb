module FiscalYearService
  module_function

  MAX_MONTHS_COUNT = 18

  # 月数が制限値以内かを確認します。
  def validate_months_range(date_from, date_to)
    DateService.months_count_from_date_span(date_from, date_to) <= MAX_MONTHS_COUNT
  end

  # 取引日付を確認します。
  def validate_journal_date(fiscal_year, date)
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
      }
    }
  end

  # 新しい会計年度用の科目一覧を、コピー元の会計年度の科目から生成します。
  def subjects_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
    subjects = Subject.where(fiscal_year: base_fiscal_year).map { |m| m.dup }
    subjects.each { |m| m.fiscal_year = new_fiscal_year}
    subjects
  end

  # 会計年度分の取引明細を取得して、削除が可能かをチェックします。
  # TODO: この先、予算・残高もチェックします。
  def fiscal_year_can_delete?(fiscal_year)
    Journal.where(fiscal_year: fiscal_year).empty?
  end

  # 会計年度分の科目一覧を取得します。(削除用です)
  def get_subjects_by_fiscal_year(fiscal_year)
    Subject.where(fiscal_year: fiscal_year).to_a
  end
end