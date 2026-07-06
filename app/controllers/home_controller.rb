class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @dashboard = LibraryDashboard.new(user: current_user)
  end
end
