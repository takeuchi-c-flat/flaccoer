class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.references :fiscal_year,      null: false,  index: true,  foreign_key: true
      t.references :subject_type,     null: false,  index: true,  foreign_key: true
      t.string     :code,             null: false,  limit: 4
      t.string     :name,             null: false
      t.integer    :report1_location
      t.integer    :report2_location
      t.integer    :report3_location
      t.integer    :report4_location
      t.integer    :report5_location
      t.boolean    :from_template,    null: false,  default: false
      t.boolean    :disabled,         null: false,  default: false
      t.boolean    :dash_board,       null: false,  default: false

      t.timestamps null: false
    end

    add_index :subjects, [:fiscal_year_id, :code], unique: true
  end
end
