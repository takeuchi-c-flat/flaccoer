require 'csv'

CSV.generate('', force_quotes: true) do |csv|
  cols = {
    'type_id' => -> (u){ u.subject_type.id.to_s },
    'コード' => -> (u){ u.code },
    '名称' => -> (u){ u.name },
    '帳票位置１' => -> (u){ (u.report1_location || 0).to_s },
    '帳票位置２' => -> (u){ (u.report2_location || 0).to_s },
    '帳票位置３' => -> (u){ (u.report3_location || 0).to_s },
    '帳票位置４' => -> (u){ (u.report4_location || 0).to_s },
    '帳票位置５' => -> (u){ (u.report5_location || 0).to_s },
    'テンプレート項目' => -> (u){ u.from_template.to_s },
    '無効' => -> (u){ u.disabled.to_s },
    'ダッシュボード表示' => -> (u){ u.dash_board.to_s }
  }

  csv << cols.keys
  @subjects.each { |m| csv << cols.map { |_k, col| col.call(m) } }
end
