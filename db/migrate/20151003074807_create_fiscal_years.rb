class CreateFiscalYears < ActiveRecord::Migration[4.2]
  def change
    create_table :fiscal_years do |t|
      t.references :user,                   null: false,  index: true,  foreign_key: true
      t.references :account_type,           null: false,  index: true
      t.references :subject_template_type,  null: false,  index: true,  foreign_key: true
      t.string     :organization_name,      null: false
      t.string     :title,                  null: false
      t.date       :date_from,              null: false
      t.date       :date_to,                null: false
      t.boolean    :locked,                 null: false,  default: false

      t.timestamps                          null: false
    end
  end
end
