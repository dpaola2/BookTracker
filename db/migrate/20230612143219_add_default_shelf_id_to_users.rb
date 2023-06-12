class AddDefaultShelfIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :shelf_id, :integer
  end
end
