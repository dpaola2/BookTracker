module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        # check username and password, render user_id and api_key as json
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          render json: { user_id: user.id, api_key: user.api_key }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end
