class SofaImporter
  attr_reader :filename

  def initialize(filename: 'public/SofaExport-17022023-212837.csv')
    @filename = filename
  end

  def csv
    @csv ||= CSV.parse(File.open(filename), headers: true)
  end

  def shelves
    @shelves ||= csv.map {|d| d["List Name"] }.uniq
  end

  def books
    @books ||= csv.map do |d|
      {
        title: d["Item Title"],
        shelf: d["List Name"]
      }
    end
  end

  def import
    shelves.map do |shelf|
      Shelf.create!(name: shelf)
    end

    books.map do |book|
      Book.create!(
        title: book[:title],
        shelf: Shelf.find_by(name: book[:shelf])
      )
    end
  end
end