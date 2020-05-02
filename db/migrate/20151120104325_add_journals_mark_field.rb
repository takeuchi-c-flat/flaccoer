class AddJournalsMarkField < ActiveRecord::Migration[4.2]
  def change
    add_column :journals, :mark, :boolean, null: false, default: false
  end
end
