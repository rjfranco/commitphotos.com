class AddPhotos < ActiveRecord::Migration
  def up
    create_table :photos do |t|
      t.integer :user_id
      t.string :url
      t.string :sha
      t.string :message
      t.string :repo

      t.timestamps
    end
  end

  def down
    drop_table :photos
  end
end
