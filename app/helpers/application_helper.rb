module ApplicationHelper
  include Pagy::Frontend

  def load_bootstrap?
    @load_bootstrap || false
  end
end
