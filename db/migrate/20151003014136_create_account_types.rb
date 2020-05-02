class CreateAccountTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :account_types do |t|
      t.string      :code,  null: false
      t.string      :name,  null: false

      t.timestamps          null: false
    end

    AccountType.create(code: 'MULTI', name: '複式簿記')
    AccountType.create(code: 'SINGLE', name: '出納帳')
  end
end
