module JournalsService
  module_function

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
end
