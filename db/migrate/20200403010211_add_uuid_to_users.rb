class AddUuidToUsers < ActiveRecord::Migration[6.0]
  # convert integer id to unique uuid's
  # https://pawelurbanek.com/uuid-order-rails

  def up
    add_column :users, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :users, :id, :integer_id
    rename_column :users, :uuid, :id
    execute 'ALTER TABLE users drop constraint users_pkey;'
    execute 'ALTER TABLE users ADD PRIMARY KEY (id);'

    # this is not working for me locally, moving on for now :/
    remove_column :users, :integer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration # bold!
  end
end
