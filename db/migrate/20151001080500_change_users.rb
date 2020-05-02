class ChangeUsers < ActiveRecord::Migration[4.2]
  def change
    # Userにadmin_userを追加
    add_column :users, :admin_user, :boolean, null: true

    # Userに初期ユーザを追加
    if User.all.empty?
      User.create(
        email: 'default@local',
        name: 'DefaultAdminUser',
        password: 'password',
        admin_user: true)
    end
  end
end
