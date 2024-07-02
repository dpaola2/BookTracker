class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    # check username and password, render user_id and api_key as json
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      render json: { user_id: user.id, api_key: user.api_key }
    else
      render json: { error: 'Invalid email or password' }, status: 401
    end
  end
end
