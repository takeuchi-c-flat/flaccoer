class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.references  :fiscal_year, null: false,  index: true,  foreign_key: true
      t.references  :subject,     null: false,  index: true,  foreign_key: true
      t.integer     :top_balance, null: false,  default: 0

      t.timestamps null: false
    end
  end
end
