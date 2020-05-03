class CreateBadgets < ActiveRecord::Migration[4.2]
  def change
    create_table :badgets do |t|
      t.references  :fiscal_year,   null: false,  index: true,  foreign_key: true
      t.references  :subject,       null: false,  index: true,  foreign_key: true
      t.integer     :total_badget,  null: false,  default: 0

      t.timestamps null: false
    end

    add_index :badgets, [:fiscal_year_id, :subject_id], unique: true
  end
end
