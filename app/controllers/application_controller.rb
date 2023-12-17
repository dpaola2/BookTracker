class ApplicationController < ActionController::Base
  include Pagy::Backend


  def set_bootstrap
    @load_bootstrap = true
  end
end
