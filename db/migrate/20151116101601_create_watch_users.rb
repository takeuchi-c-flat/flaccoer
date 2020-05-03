class CreateWatchUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :watch_users do |t|
      t.references :fiscal_year, null: false, index: true, foreign_key: true
      t.references :user,        null: false, index: true, foreign_key: true
      t.boolean    :can_modify,  null: false, default: false

      t.timestamps null: false
    end

    add_index :watch_users, [:fiscal_year_id, :user_id], unique: true
  end
end
