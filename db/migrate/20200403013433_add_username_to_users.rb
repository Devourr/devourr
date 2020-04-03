class AddUsernameToUsers < ActiveRecord::Migration[6.0]
  # don't need users' full names
  # unique username will help users find each other in the app

  def up
    rename_column :users, :first_name, :name
    rename_column :users, :last_name, :user_name
  end

  def down
    rename_column :users, :name, :first_name
    rename_column :users, :user_name, :last_name
  end
end
