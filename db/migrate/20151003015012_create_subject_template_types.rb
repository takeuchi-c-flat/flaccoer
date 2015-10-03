class CreateSubjectTemplateTypes < ActiveRecord::Migration
  def change
    create_table :subject_template_types do |t|
      t.references  :account_type,  null: false,  foreign_key: true
      t.string      :name,          null: false

      t.timestamps                  null: false
    end
  end
end
