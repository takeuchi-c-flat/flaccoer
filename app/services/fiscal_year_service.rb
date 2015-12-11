module FiscalYearService
  module_function

  MAX_MONTHS_COUNT = 18

  # Userがアクセス可能な会計年度を取得します。
  def accessible_fiscal_years(user)
    my_fiscal_years(user) + can_watch_fiscal_years(user)
  end

  # Userの所有する会計年度を取得します。
  def my_fiscal_years(user)
    FiscalYear.where(user: user).order(date_from: :desc)
  end

  # Userがアクセスを許可された会計年度を取得します。
  def can_watch_fiscal_years(user)
    WatchUser.where(user: user).eager_load(:fiscal_year).
      map { |m| m.fiscal_year }.
      sort_by { |m| m.date_from }.
      reverse
  end

  # 現在の会計年度とUserがマッチしているかを確認します。
  def user_match?(current_fiscal_year, current_user)
    return false if current_fiscal_year.nil?
    current_fiscal_year.user == current_user || current_fiscal_year.can_access?(current_user)
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
  def create_subjects_from_template(subject_template_type, new_fiscal_year)
    templates = SubjectTemplate.where(subject_template_type: subject_template_type)
    new_fiscal_year.subjects = templates.map { |template|
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
  def create_subjects_from_base_fiscal_year(base_fiscal_year, new_fiscal_year, with_carry = false)
    new_subjects = Subject.where(fiscal_year: base_fiscal_year).map { |m| m.dup }
    new_subjects.each { |m| m.fiscal_year = new_fiscal_year}
    new_fiscal_year.subjects = new_subjects

    # 繰越の場合は、予算・残高の生成も行う
    if with_carry
      carry_balances_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
      carry_badgets_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
    end
  end

  # 期首残高をコピー元の会計年度から引き継ぎ、new_fiscal_year.subjectsに設定します。
  def carry_balances_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
    journals = Journal.
      eager_load(subject_debit: [:subject_type, :balance]).
      eager_load(subject_credit: [:subject_type, :balance]).
      where(fiscal_year: base_fiscal_year)
    base_fiscal_year.subjects.
      select { |m| m.subject_type.debit_and_credit? }.
      each { |m|
        subject_journals = journals.select { |j| j.subject_debit == m || j.subject_credit == m }
        balance = m.balance.try(&:top_balance) || 0
        balance += subject_journals.map { |j| j.price_for_balance(m) }.inject(:+) || 0
        next if balance.zero?
        new_fiscal_year.subjects.
          find { |s| s.code == m.code }.
          tap { |s|
            s.balance = Balance.new(fiscal_year: new_fiscal_year, subject: s, top_balance: balance)
          }
      }
  end

  # 年間予算をコピー元の会計年度から引き継ぎ、new_fiscal_year.subjectsに設定します。
  def carry_badgets_from_base_fiscal_year(base_fiscal_year, new_fiscal_year)
    base_badgets = Badget.eager_load(:subject).where(fiscal_year: base_fiscal_year)
    new_fiscal_year.subjects.each { |s|
      total_badget = base_badgets.find { |base| base.subject.code == s.code }.try(&:total_badget) || 0
      next if total_badget.zero?
      s.badget = Badget.new(fiscal_year: new_fiscal_year, subject: s, total_badget: total_badget)
    }
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
    today = Date.today
    return today if fiscal_year.nil?
    journal_date = today if journal_date.nil?
    return fiscal_year.date_from if journal_date < fiscal_year.date_from
    return fiscal_year.date_to if fiscal_year.date_to < journal_date
    journal_date
  end
end
