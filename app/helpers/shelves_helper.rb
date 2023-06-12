module ShelvesHelper
  def shelves_for_select(user)
    Shelf.all.map { |shelf| [shelf.name, shelf.id] }
  end
end
