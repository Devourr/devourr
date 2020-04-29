class CreateBlockedUserNames < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_user_names do |t|
      t.string :user_name, null: false, unique: true

      t.timestamps
    end
  end
end
