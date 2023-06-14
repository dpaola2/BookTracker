module BooksHelper
  def expand_accordion_class_button(book)
    if book.isbn.present?
      "collapsed"
    else
      ""
    end
  end

  def expand_accordion_class(book)
    if book.isbn.present?
      ""
    else
      "show"
    end
  end
end
