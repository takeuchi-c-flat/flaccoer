module JournalsService
  module_function

  # 取引明細の月選択タブ用のHASHのリストを取得します。
  def create_journal_months(fiscal_year, journal_date)
    if fiscal_year.tab_type == 1
      return create_journal_months_per_2months(fiscal_year.date_from, fiscal_year.date_to, journal_date)
    elsif fiscal_year.tab_type == 2
      return create_journal_months_all(fiscal_year.date_from, fiscal_year.date_to, journal_date)
    else
      return create_journal_months_per_1month(fiscal_year.date_from, fiscal_year.date_to, journal_date)
    end
  end

  # 取引明細の月選択タブ用のHASHのリストを取得します。(1ヶ月ごと)
  def create_journal_months_per_1month(date_from, date_to, journal_date)
    months = DateService.enumerate_months_from_date_span(date_from, date_to)
    months.map { |month|
      {
        title: month.strftime('%Y-%m'),
        id: "tab#{month.strftime('%Y%m')}",
        class: journal_date.beginning_of_month == month ? 'active' : nil
      }
    }
  end

  # 取引明細の月選択タブ用のHASHのリストを取得します。(2ヶ月ごと + 直近2ヶ月)
  def create_journal_months_per_2months(date_from, date_to, journal_date)
    months = DateService.enumerate_months_from_date_span(date_from, date_to)
    need_last_tab = months.length != 1 && journal_date.beginning_of_month != months[0]

    # 会計期間内の月から、２ヶ月ごとにタブを生成
    index = 0
    tabs = []
    while index < months.length do
      month = months[index]

      if index == months.length - 1
        tab = {
          title: month.strftime('%Y-%m'),
          id: "tab#{month.strftime('%Y%m')}-#{month.strftime('%Y%m')}",
          class: !need_last_tab && journal_date.beginning_of_month == month ? 'active' : nil
        }
      else
        next_month = index == months.length - 1 ? month : months[index + 1]
        tab = {
          title: month.strftime('%Y-%m') + '〜' + next_month.strftime('%m'),
          id: "tab#{month.strftime('%Y%m')}-#{next_month.strftime('%Y%m')}",
          class: !need_last_tab && journal_date.beginning_of_month == month ? 'active' : nil
        }
      end
      tabs << tab
      index += 2
    end

    # 直近２ヶ月のタブを追加
    if need_last_tab
      month = journal_date.beginning_of_month
      prev_month = month.ago(1.months)
      tab = {
        title: '直近2ヶ月',
        id: "tabLast#{prev_month.strftime('%Y%m')}-#{month.strftime('%Y%m')}",
        class: 'active'
      }
      tabs << tab
    end

    tabs
  end

  # 取引明細の月選択タブ用のHASHのリストを取得します。(通期)
  def create_journal_months_all(date_from, date_to, journal_date)
    # 会計期間内の月から、２ヶ月ごとにタブを生成
    months = DateService.enumerate_months_from_date_span(date_from, date_to)
    last_month_index = months.length - 1;
    tab = {
      title: '仕訳一覧',
      id: "tabAll#{months.first.strftime('%Y%m')}-#{months.last.strftime('%Y%m')}",
      class: 'active'
    }

    [tab]
  end

  # タブ名称に応じた、取引明細を取得します。
  def journal_list_from_tab_name(tab_name, fiscal_year)
    year_months = tab_name.scan(/\d{6}/)
    from_year_month = year_months[0]
    to_year_month = year_months.length == 1 ? year_months[0] : year_months[1]
    (from, to) = DateService.date_range_from_year_month(from_year_month, to_year_month)
    journals = Journal.
      where(fiscal_year: fiscal_year).
      where('journal_date BETWEEN ? AND ?', from, to).
      order([:journal_date, :id])

    fiscal_year.list_desc ? journals.reverse : journals
  end
end
