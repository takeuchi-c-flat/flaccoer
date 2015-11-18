class AddSubjectTemplateCashBook < ActiveRecord::Migration
  def change
    # 既に追加済の場合は終了する。
    return if SubjectTemplateType.find_by(name: '出納帳').present?

    template_type_cash_book = SubjectTemplateType.create!(
      account_type: AccountType.find_by(code: 'SINGLE'),
      name: '出納帳'
    )
    type = AccountType.find_by(code: 'SINGLE')
    type_property = SubjectType.find_by(account_type: type, name: '現預金')
    type_profit = SubjectType.find_by(account_type: type, name: '収入の部')
    type_loss = SubjectType.find_by(account_type: type, name: '支出の部')

    # 出納帳
    subjects = [
      # 現預金の部
      { type: type_property, code: '101', name: '現金', report1_location: 1 },
      { type: type_property, code: '102', name: '普通預金', report1_location: 2 },
      # 収入の部
      { type: type_profit, code: '391', name: '雑収入' },
      # 支出の部
      { type: type_loss, code: '491', name: '雑費' }
    ]

    subjects.each do |subject|
      SubjectTemplate.create!(
        subject_template_type: template_type_cash_book,
        subject_type: subject[:type],
        code: subject[:code],
        name: subject[:name],
        report1_location: subject[:report1_location],
        report2_location: subject[:report2_location])
    end
  end
end
