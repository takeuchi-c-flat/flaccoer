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
end
