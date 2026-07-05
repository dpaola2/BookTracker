class AddMetadataToIsbnSearchResults < ActiveRecord::Migration[7.0]
  def change
    add_column :isbn_search_results, :subjects, :string
    add_column :isbn_search_results, :synopsis, :text
    add_column :isbn_search_results, :pages, :integer
    add_column :isbn_search_results, :date_published, :string
  end
end
