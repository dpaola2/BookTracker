class AddForeignKeysToBooksAndShelves < ActiveRecord::Migration[7.0]
  def up
    add_column :books, :user_id, :integer
    add_column :shelves, :user_id, :integer

    Book.update_all(user_id: User.first.id)
    Shelf.update_all(user_id: User.first.id)
  end

  def down
    remove_column :books, :user_id
    remove_column :shelves, :user_id
  end
end
