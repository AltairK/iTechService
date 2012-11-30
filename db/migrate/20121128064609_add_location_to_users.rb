class AddLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :location_id, :integer
    add_index :users, :location_id
    add_index :users, :username
  end
end
