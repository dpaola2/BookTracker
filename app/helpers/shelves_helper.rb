module ShelvesHelper
  def shelves_for_select(user)
    user.shelves.all.map { |shelf| [shelf.name, shelf.id] }
  end
end
