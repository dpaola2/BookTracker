namespace :books do
  desc "Classify unclassified books (fiction/nonfiction + genres) via the Claude API"
  task classify: :environment do
    $stdout.sync = true
    scope = Book.where(classification: nil)
    total = scope.count
    puts "Classifying #{total} books..."

    scope.find_each.with_index(1) do |book, index|
      success = BookClassifier.new(book: book).classify
      puts "[#{index}/#{total}] #{success ? 'ok' : 'FAILED'} - #{book.title}"
    end
  end
end
