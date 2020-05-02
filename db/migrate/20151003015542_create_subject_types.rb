class CreateSubjectTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :subject_types do |t|
      t.references  :account_type,          null: false,  index: true,  foreign_key: true
      t.string      :name,                  null: false
      t.string      :short_name,            null: false
      t.string      :debit_and_credit_name, null: false
      t.string      :profit_and_loss_name,  null: false
      t.boolean     :debit,                 null: false
      t.boolean     :credit,                null: false
      t.boolean     :debit_and_credit,      null: false
      t.boolean     :profit_and_loss,       null: false

      t.timestamps                          null: false
    end

    # 複式簿記用の科目種別を追加
    multi = AccountType.find_by(code: 'MULTI')
    [
      { name: '資産の部', short_name: '資産', dc: true, pl: false },
      { name: '負債・資本の部', short_name: '負債', dc: false, pl: false },
      { name: '支出の部', short_name: '支出', dc: true, pl: true },
      { name: '収入の部', short_name: '収入', dc: false, pl: true }
    ].each { |hash|
      SubjectType.create(
        account_type: multi,
        name: hash[:name],
        short_name: hash[:short_name],
        debit_and_credit_name: hash[:dc] ? '借方科目' : '貸方科目',
        profit_and_loss_name: hash[:pl] ? '損益勘定' : '貸借勘定',
        debit: hash[:dc],
        credit: !hash[:dc],
        debit_and_credit: !hash[:pl],
        profit_and_loss: hash[:pl]
      )
    }
    # 出納帳用の科目種別を追加
    single = AccountType.find_by(code: 'SINGLE')
    [
      { name: '支出の部', short_name: '支出', dc: false, pl: true },
      { name: '収入の部', short_name: '収入', dc: true, pl: true },
      { name: '現預金', short_name: '現預金', dc: true, pl: false }
    ].each { |hash|
      SubjectType.create(
        account_type: single,
        name: hash[:name],
        short_name: hash[:short_name],
        debit_and_credit_name: hash[:dc] ? '収入' : '支出',
        profit_and_loss_name: hash[:pl] ? '収支' : '現預金',
        debit: hash[:dc],
        credit: !hash[:dc],
        debit_and_credit: !hash[:pl],
        profit_and_loss: hash[:pl]
      )
    }
  end
end
