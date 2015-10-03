module DateService
  module_function

  # 日付の範囲から月を羅列します。
  def enumerate_months_from_date_span(date_from, date_to)
    date = date_from.beginning_of_month
    months = []
    while date <= date_to.beginning_of_month
      months << date
      date = date.next_month
    end
    months
  end

  # 日付の範囲から月数(期間ではなく暦月の数)を取得します。
  def months_count_from_date_span(date_from, date_to)
    enumerate_months_from_date_span(date_from, date_to).length
  end

  # 日付の指定順序を確認します。
  def validate_date_order(date_from, date_to)
    date_from <= date_to
  end
end
