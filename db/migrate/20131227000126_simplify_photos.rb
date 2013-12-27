class SimplifyPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :email, :string
    add_column :photos, :user_name, :string
    remove_column :photos, :user_id
    remove_column :photos, :sha
  end
end
