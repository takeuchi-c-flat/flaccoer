class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :email_for_index, null: false
      t.string :name, null: false
      t.string :hashed_password
      t.boolean :suspended, null: false, default: false

      t.timestamps null: false
    end

    add_index :users, :email_for_index, unique: true
  end
end
