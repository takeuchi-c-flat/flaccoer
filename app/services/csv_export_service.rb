require 'csv'

module CsvExportService
  module_function

  JOURNAL_COLS = {
    '取引日' => ->(u) { u.journal_date.strftime('%Y-%m-%d') },
    '借方コード' => ->(u) { u.subject_debit.code },
    '借方名称' => ->(u) { u.subject_debit.name },
    '貸方コード' => ->(u) { u.subject_credit.code },
    '貸方名称' => ->(u) { u.subject_credit.name },
    '金額' => ->(u) { u.price.to_s },
    '摘要' => ->(u) { u.comment }
  }
  SUBJECT_COLS = {
    'type_id' => ->(u) { u.subject_type.id.to_s },
    'コード' => ->(u) { u.code },
    '名称' => ->(u) { u.name },
    '帳票位置１' => ->(u) { (u.report1_location || 0).to_s },
    '帳票位置２' => ->(u) { (u.report2_location || 0).to_s },
    '帳票位置３' => ->(u) { (u.report3_location || 0).to_s },
    '帳票位置４' => ->(u) { (u.report4_location || 0).to_s },
    '帳票位置５' => ->(u) { (u.report5_location || 0).to_s },
    'テンプレート項目' => ->(u) { u.from_template.to_s },
    '無効' => -> (u) { u.disabled.to_s },
    'ダッシュボード表示' => ->(u) { u.dash_board.to_s }
  }
  BALANCE_COLS = {
    '科目コード' => ->(u) { u.subject.code },
    '科目名称' => ->(u) { u.subject.name },
    '期首残高' => ->(u) { u.top_balance.to_s }
  }
  BADGET_COLS = {
    '科目コード' => ->(u) { u.subject.code },
    '科目名称' => ->(u) { u.subject.name },
    '年間予算' => ->(u) { u.total_badget.to_s }
  }

  # 取引明細のCSVデータを生成します。
  def create_journals_export_csv_data(journals)
    CSV.generate('', force_quotes: true) do |csv|
      csv << JOURNAL_COLS.keys
      journals.each { |m| csv << JOURNAL_COLS.map { |_k, col| col.call(m) } }
    end
  end

  # 勘定科目のCSVデータを生成します。
  def create_subjects_export_csv_data(subjects)
    CSV.generate('', force_quotes: true) do |csv|
      csv << SUBJECT_COLS.keys
      subjects.each { |m| csv << SUBJECT_COLS.map { |_k, col| col.call(m) } }
    end
  end

  # 期首残高のCSVデータを生成します。
  def create_balances_export_csv_data(balances)
    CSV.generate('', force_quotes: true) do |csv|
      csv << BALANCE_COLS.keys
      balances.each { |m| csv << BALANCE_COLS.map { |_k, col| col.call(m) } }
    end
  end

  # 年間予算のCSVデータを生成します。
  def create_badgets_export_csv_data(badgets)
    CSV.generate('', force_quotes: true) do |csv|
      csv << BADGET_COLS.keys
      badgets.each { |m| csv << BADGET_COLS.map { |_k, col| col.call(m) } }
    end
  end
end
