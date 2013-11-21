class AddUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :github_id
      t.string :github_token
      t.string :username
      t.string :email
      t.string :name
      t.datetime :banned_until
      t.datetime :last_login
      t.string :api_key

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
