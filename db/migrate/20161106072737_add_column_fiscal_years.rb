class AddColumnFiscalYears < ActiveRecord::Migration[4.2]
  def up
    add_column :fiscal_years, :tab_type, :integer
    add_column :fiscal_years, :list_desc, :boolean
  end

  def down
    remove_column :fiscal_years, :tab_type, :integer
    remove_column :fiscal_years, :list_desc, :boolean
    end
end
