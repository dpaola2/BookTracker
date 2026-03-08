require "test_helper"

class GoodReadsImporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @fixture_path = Rails.root.join("test/fixtures/files/goodreads_export.csv").to_s
    @importer = GoodReadsImporter.new(user: @user, filename: @fixture_path)
  end

  test "parses csv into books array" do
    assert_equal 4, @importer.books.length
  end

  test "extracts title from csv" do
    assert_equal "The Great Gatsby", @importer.books.first[:title]
  end

  test "extracts author from csv" do
    assert_equal "Fitzgerald, F. Scott", @importer.books.first[:author]
  end

  test "strips quotes and equals from isbn" do
    assert_equal "9780743273565", @importer.books.first[:isbn]
  end

  test "maps read shelf to liked" do
    assert_equal "👍 Books: Liked", @importer.books.first[:shelf]
  end

  test "maps abandoned books to abandoned shelf" do
    dune = @importer.books.find { |b| b[:title] == "Dune" }

    assert_equal "👎 Abandoned / Disliked", dune[:shelf]
  end

  test "maps currently-reading to in progress" do
    clean_code = @importer.books.find { |b| b[:title] == "Clean Code" }

    assert_equal "📖 In Progress", clean_code[:shelf]
  end

  test "maps to-read to to read" do
    hobbit = @importer.books.find { |b| b[:title] == "The Hobbit" }

    assert_equal "📚 To Read", hobbit[:shelf]
  end

  test "extracts review as comments" do
    assert_equal "A classic novel", @importer.books.first[:comments]
  end

  test "extracts private notes as comments" do
    dune = @importer.books.find { |b| b[:title] == "Dune" }

    assert_equal "Left it halfway", dune[:comments]
  end
end
