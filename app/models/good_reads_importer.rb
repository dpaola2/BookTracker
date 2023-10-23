class GoodReadsImporter
  attr_reader :filename, :user, :csv

  def initialize(filename: 'public/goodreads_library_export.csv', user:)
    @filename = filename
    @user = user
  end

  def csv
    @csv ||= CSV.parse(File.open(filename), headers: true)
  end

  def books
    @books ||= csv.map do |d|
      {
        title: d["Title"],
        author: d["Author l-f"],
        shelf: shelf_name_from_record(record: d),
        comments: comments_from_record(record: d),
        isbn: d["ISBN13"].tr("\"","").tr("=","")
      }
    end
  end

  def import!
    books.map do |book|
      # Create the record

      if user.books.exists?(title: book[:title])
        # just put it on the right shelf
        user.books.find_by(title: book[:title]).update(
          shelf: Shelf.find_by(name: book[:shelf]),
          isbn: book[:isbn]
        )
      else
        user.books.create!(
          title: book[:title],
          author: book[:author],
          shelf: Shelf.find_by(name: book[:shelf]),
          isbn: book[:isbn]
        )
      end

      # update comments and such
      book = user.books.find_by(title: book[:title])

      if book.comments.blank?
        book.update(comments: book[:comments])
      else
        book.update(comments: "#{ book.comments } #{ book[:comments] }")
      end

      # search for the ISBN if we don't have an image
      if !book.image.attached?
        isbn_result = IsbnSearcher.new(book: book).find_by_isbn
        if isbn_result
          IsbnAssigner.new(book: book, isbn_search_result: isbn_result).assign
        end
      end
    end
  end

  def shelf_name_from_record(record:)
    if record["Exclusive Shelf"] == "read"
      if record["Bookshelves"].present?
        if record["Bookshelves"].index("abandoned").present? # put it into the abandoned shelf
          "👎 Abandoned / Disliked"
        else
          "👍 Books: Liked"    
        end
      else
        "👍 Books: Liked"
      end
    elsif record["Exclusive Shelf"] == "currently-reading"
      "📖 In Progress"
    else
      "📚 To Read"
    end
  end

  def comments_from_record(record:)
    review = record["My Review"]
    notes = record["Private Notes"]

    [review, notes].compact.to_sentence
  end
end