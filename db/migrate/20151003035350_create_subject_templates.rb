class CreateSubjectTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :subject_templates do |t|
      t.references  :subject_template_type, null:false, index: true,  foreign_key: true
      t.references  :subject_type,          null:false,               foreign_key: true
      t.string      :code,                  null:false
      t.string      :name,                  null:false
      t.integer     :report1_location
      t.integer     :report2_location
      t.integer     :report3_location
      t.integer     :report4_location
      t.integer     :report5_location

      t.timestamps null: false
    end
  end
end
