class CreateBalances < ActiveRecord::Migration[4.2]
  def change
    create_table :balances do |t|
      t.references  :fiscal_year, null: false,  index: true,  foreign_key: true
      t.references  :subject,     null: false,  index: true,  foreign_key: true
      t.integer     :top_balance, null: false,  default: 0

      t.timestamps null: false
    end

    add_index :balances, [:fiscal_year_id, :subject_id], unique: true
  end
end
