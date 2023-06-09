class CreateIsbnSearchResults < ActiveRecord::Migration[7.0]
  def change
    create_table :isbn_search_results do |t|
      t.integer :book_id
      t.string :image_url
      t.string :title
      t.string :authors
      t.string :isbn13
      t.string :isbn10

      t.timestamps
    end
  end
end
