require "test_helper"

class SofaImporterTest < ActiveSupport::TestCase
  setup do
    @fixture_path = Rails.root.join("test/fixtures/files/sofa_export.csv").to_s
    @importer = SofaImporter.new(filename: @fixture_path)
  end

  test "parses csv and extracts books" do
    assert_equal 4, @importer.books.length
  end

  test "extracts book title" do
    assert_equal "The Great Gatsby", @importer.books.first[:title]
  end

  test "extracts shelf name" do
    assert_equal "Favorites", @importer.books.first[:shelf]
  end

  test "extracts unique shelf names" do
    assert_equal 3, @importer.shelves.length
    assert_includes @importer.shelves, "Favorites"
    assert_includes @importer.shelves, "Sci-Fi"
    assert_includes @importer.shelves, "Programming"
  end
end
