class AddJournalsMarkField < ActiveRecord::Migration
  def change
    add_column :journals, :mark, :boolean, null: false, default: false
  end
end
