class AddSubjectTemplateBlue < ActiveRecord::Migration
  def change
    # 既に追加済の場合は終了する。
    return if SubjectTemplateType.find_by(name: '個人事業主(青色申告)').present?

    template_type_freelance_blue = SubjectTemplateType.create!(
      account_type: AccountType.find_by(code: 'MULTI'),
      name: '個人事業主(青色申告)'
    )
    type = AccountType.find_by(code: 'MULTI')
    type_debit = SubjectType.find_by(account_type: type, name: '資産の部')
    type_credit = SubjectType.find_by(account_type: type, name: '負債・資本の部')
    type_profit = SubjectType.find_by(account_type: type, name: '収入の部')
    type_loss = SubjectType.find_by(account_type: type, name: '支出の部')

    # 個人事業主(青色申告)
    subjects = [
      # 資産の部
      { type: type_debit, code: '101', name: '現金', report1_location: 1 },
      { type: type_debit, code: '102', name: '当座預金', report1_location: 2 },
      { type: type_debit, code: '103', name: '定期預金', report1_location: 3 },
      { type: type_debit, code: '104', name: '普通預金', report1_location: 4 },
      { type: type_debit, code: '105', name: '受取手形', report1_location: 5 },
      { type: type_debit, code: '106', name: '売掛金', report1_location: 6 },
      { type: type_debit, code: '107', name: '有価証券', report1_location: 7 },
      { type: type_debit, code: '108', name: '棚卸資産', report1_location: 8 },
      { type: type_debit, code: '109', name: '前払金', report1_location: 9 },
      { type: type_debit, code: '110', name: '貸付金', report1_location: 10 },
      { type: type_debit, code: '111', name: '建物', report1_location: 11 },
      { type: type_debit, code: '112', name: '建物付属設備', report1_location: 12 },
      { type: type_debit, code: '113', name: '機械装置', report1_location: 13 },
      { type: type_debit, code: '114', name: '車両運搬具', report1_location: 14 },
      { type: type_debit, code: '115', name: '工具 器具 備品', report1_location: 15 },
      { type: type_debit, code: '116', name: '土地', report1_location: 16 },
      { type: type_debit, code: '190', name: '事業主貸', report1_location: 24 },
      # 負債・資本の部
      { type: type_credit, code: '201', name: '支払手形', report1_location: 31 },
      { type: type_credit, code: '202', name: '買掛金', report1_location: 32 },
      { type: type_credit, code: '203', name: '借入金', report1_location: 33 },
      { type: type_credit, code: '204', name: '未払金', report1_location: 34 },
      { type: type_credit, code: '205', name: '前受金', report1_location: 35 },
      { type: type_credit, code: '206', name: '預り金', report1_location: 36 },
      { type: type_credit, code: '251', name: '貸倒引当金', report1_location: 44 },
      { type: type_credit, code: '281', name: '事業主借', report1_location: 52 },
      { type: type_credit, code: '291', name: '元入金', report1_location: 53 },
      # 収入の部
      { type: type_profit, code: '301', name: '売上', report2_location: 1 },
      { type: type_profit, code: '391', name: '雑収入', report2_location: 1 },
      # 支出の部
      { type: type_loss, code: '401', name: '期首商品棚卸高', report2_location: 2 },
      { type: type_loss, code: '402', name: '仕入', report2_location: 3 },
      { type: type_loss, code: '403', name: '期末商品棚卸高', report2_location: 5 },
      { type: type_loss, code: '411', name: '租税公課', report2_location: 8 },
      { type: type_loss, code: '412', name: '荷造運賃', report2_location: 9 },
      { type: type_loss, code: '413', name: '水道光熱費', report2_location: 10 },
      { type: type_loss, code: '414', name: '旅費交通費', report2_location: 11 },
      { type: type_loss, code: '415', name: '通信費', report2_location: 12 },
      { type: type_loss, code: '416', name: '広告宣伝費', report2_location: 13 },
      { type: type_loss, code: '417', name: '接待交際費', report2_location: 14 },
      { type: type_loss, code: '418', name: '損害保険料', report2_location: 15 },
      { type: type_loss, code: '419', name: '修繕費', report2_location: 16 },
      { type: type_loss, code: '420', name: '消耗品費', report2_location: 17 },
      { type: type_loss, code: '421', name: '減価償却費', report2_location: 18 },
      { type: type_loss, code: '422', name: '福利厚生費', report2_location: 19 },
      { type: type_loss, code: '423', name: '給料賃金', report2_location: 20 },
      { type: type_loss, code: '424', name: '外注工賃', report2_location: 21 },
      { type: type_loss, code: '425', name: '利子割引料', report2_location: 22 },
      { type: type_loss, code: '426', name: '地代家賃', report2_location: 23 },
      { type: type_loss, code: '427', name: '貸倒金', report2_location: 24 },
      { type: type_loss, code: '491', name: '雑費', report2_location: 31 }
    ]

    subjects.each do |subject|
      SubjectTemplate.create!(
        subject_template_type: template_type_freelance_blue,
        subject_type: subject[:type],
        code: subject[:code],
        name: subject[:name],
        report1_location: subject.try(:report1_location),
        report2_location: subject.try(:report2_location)
      )
    end
  end
end
