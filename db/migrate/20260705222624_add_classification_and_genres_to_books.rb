class AddClassificationAndGenresToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :classification, :string
    add_column :books, :genres, :string
  end
end
