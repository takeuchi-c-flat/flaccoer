class CreateJournals < ActiveRecord::Migration[4.2]
  def change
    create_table :journals do |t|
      t.references :fiscal_year,        null: false,  index: true,  foreign_key: true
      t.date       :journal_date,       null: false
      t.integer    :subject_debit_id,   null: false,  index: true
      t.integer    :subject_credit_id,  null: false,  index: true
      t.integer    :price,              null: false,  default: 0
      t.string     :comment

      t.timestamps null: false
    end

    # 項目名とTABLE名が異なる項目のforeign_keyを追加
    add_foreign_key(:journals, :subjects, column: :subject_debit_id)
    add_foreign_key(:journals, :subjects, column: :subject_credit_id)
  end
end
