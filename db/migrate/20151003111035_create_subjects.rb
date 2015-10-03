class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.references :fiscal_year,      null: false,  index: true,  foreign_key: true
      t.references :subject_type,     null: false,  index: true,  foreign_key: true
      t.string     :code,             null: false,  limit: 3
      t.string     :name,             null: false
      t.integer    :report1_location
      t.integer    :report2_location
      t.integer    :report3_location
      t.integer    :report4_location
      t.integer    :report5_location

      t.timestamps null: false
    end
  end
end
