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
      { type: type_debit, code: '101', name: '現金' },
      { type: type_debit, code: '102', name: '当座預金' },
      { type: type_debit, code: '103', name: '定期預金' },
      { type: type_debit, code: '104', name: '普通預金' },
      { type: type_debit, code: '105', name: '受取手形' },
      { type: type_debit, code: '106', name: '売掛金' },
      { type: type_debit, code: '107', name: '有価証券' },
      { type: type_debit, code: '108', name: '棚卸資産' },
      { type: type_debit, code: '109', name: '前払金' },
      { type: type_debit, code: '110', name: '貸付金' },
      { type: type_debit, code: '111', name: '建物' },
      { type: type_debit, code: '112', name: '建物付属設備' },
      { type: type_debit, code: '113', name: '機械装置' },
      { type: type_debit, code: '114', name: '車両運搬具' },
      { type: type_debit, code: '115', name: '工具 器具 備品' },
      { type: type_debit, code: '116', name: '土地' },
      { type: type_debit, code: '190', name: '事業主貸' },
      # 負債・資本の部
      { type: type_credit, code: '201', name: '支払手形' },
      { type: type_credit, code: '202', name: '買掛金' },
      { type: type_credit, code: '203', name: '借入金' },
      { type: type_credit, code: '204', name: '未払金' },
      { type: type_credit, code: '205', name: '前受金' },
      { type: type_credit, code: '206', name: '預り金' },
      { type: type_credit, code: '251', name: '貸倒引当金' },
      { type: type_credit, code: '281', name: '事業主借' },
      { type: type_credit, code: '291', name: '元入金' },
      # 収入の部
      { type: type_profit, code: '301', name: '売上', report1_location: 1 },
      { type: type_profit, code: '381', name: '家事消費等', report1_location: 2 },
      { type: type_profit, code: '391', name: '雑収入', report1_location: 3 },
      # 支出の部
      { type: type_loss, code: '401', name: '期首商品棚卸高' },
      { type: type_loss, code: '402', name: '仕入', report1_location: 4 },
      { type: type_loss, code: '403', name: '期末商品棚卸高' },
      { type: type_loss, code: '411', name: '租税公課' },
      { type: type_loss, code: '412', name: '荷造運賃' },
      { type: type_loss, code: '413', name: '水道光熱費' },
      { type: type_loss, code: '414', name: '旅費交通費' },
      { type: type_loss, code: '415', name: '通信費' },
      { type: type_loss, code: '416', name: '広告宣伝費' },
      { type: type_loss, code: '417', name: '接待交際費' },
      { type: type_loss, code: '418', name: '損害保険料' },
      { type: type_loss, code: '419', name: '修繕費' },
      { type: type_loss, code: '420', name: '消耗品費' },
      { type: type_loss, code: '421', name: '減価償却費' },
      { type: type_loss, code: '422', name: '福利厚生費' },
      { type: type_loss, code: '423', name: '給料賃金' },
      { type: type_loss, code: '424', name: '外注工賃' },
      { type: type_loss, code: '425', name: '利子割引料' },
      { type: type_loss, code: '426', name: '地代家賃' },
      { type: type_loss, code: '427', name: '貸倒金' },
      { type: type_loss, code: '491', name: '雑費' }
    ]

    subjects.each do |subject|
      SubjectTemplate.create!(
        subject_template_type: template_type_freelance_blue,
        subject_type: subject[:type],
        code: subject[:code],
        name: subject[:name],
        report1_location: subject[:report1_location],
        report2_location: subject[:report2_location])
    end
  end
end
