module JournalsService
  module_function

  CLASS_NAME = 'JournalsService'

  # 取引明細の月選択タブ用のHASHのリストを取得します。
  def create_journal_months(fiscal_year, journal_date)
    months = DateService.enumerate_months_from_date_span(fiscal_year.date_from, fiscal_year.date_to)
    months.map { |month|
      {
        title: month.strftime('%Y-%m'),
        id: "tab#{month.strftime('%Y%m')}",
        class: journal_date.beginning_of_month == month ? 'active' : nil
      }
    }
  end

  # タブ名称に応じた、取引明細を取得します。
  def journal_list_from_tab_name(tab_name, fiscal_year)
    (from, to) = DateService.date_range_from_year_month(tab_name.match(/\d{6}/)[0])
    Journal.
      where(fiscal_year: fiscal_year).
      where('journal_date BETWEEN ? AND ?', from, to).
      order([:journal_date, :id])
  end

  # 使用ランキング順の借方・貸方勘定科目のListを取得します。(Cache有効)
  def get_subject_list_with_usage_ranking(fiscal_year, for_debit)
    debit_credit = for_debit ? 'debit' : 'credit'
    cache_key = "#{CLASS_NAME}#get_subject_list_with_usage_ranking(#{fiscal_year.id}-#{debit_credit})"
    Rails.cache.fetch(cache_key, expires_in: 1.day) {
      create_subject_list_with_usage_ranking(fiscal_year, for_debit)
    }
  end

  # 使用ランキング順の借方・貸方勘定科目のListを生成します。
  def create_subject_list_with_usage_ranking(fiscal_year, for_debit)
    rankings = for_debit ? get_subject_debit_usage_ranking(fiscal_year) : get_subject_credit_usage_ranking(fiscal_year)
    subjects = get_subject_list(fiscal_year, false).each { |subject|
      ranking = rankings.find { |m| m.id == subject.id }
      subject.usage_count = ranking.nil? ? 0 : ranking.usage_count
    }
    subjects.sort_by { |subject| "#{(1000 - subject.usage_count).to_s.rjust(4, '0')}|#{subject.code}" }.to_a
  end

  # 使用ランキング付きの借方勘定科目のListを取得します。
  def get_subject_debit_usage_ranking(fiscal_year)
    all_journals = Journal.where(fiscal_year: fiscal_year).eager_load(:subject_debit)
    all_journals.
      group_by { |journal| journal.subject_debit }.
      map { |subject, journals| subject.tap { |s| s.usage_count = journals.length } }.
      reject { |subject| subject.disabled }
  end

  # 使用ランキング付きの借方勘定科目のListを取得します。
  def get_subject_credit_usage_ranking(fiscal_year)
    all_journals = Journal.where(fiscal_year: fiscal_year).eager_load(:subject_credit)
    all_journals.
      group_by { |journal| journal.subject_credit }.
      map { |subject, journals| subject.tap { |s| s.usage_count = journals.length } }.
      reject { |subject| subject.disabled }
  end

  # 会計年度分の勘定科目のリストを取得します。
  def get_subject_list(fiscal_year, with_sort = true)
    list = Subject.where(fiscal_year: fiscal_year, disabled: false).eager_load(:subject_type)
    return list unless with_sort
    list.sort_by { |m| m.code }
  end
end
