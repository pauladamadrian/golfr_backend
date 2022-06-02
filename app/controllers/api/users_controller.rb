module Api
  # Controller that handles authorization and user data fetching
  class UsersController < ApplicationController
    include Devise::Controllers::Helpers

    before_action :logged_in!, only: [:show]
    before_action :correct_user, only: [:show]

    def show
      user = User.find(params[:id])
      if user.blank?
        render json: {
          errors: [
            'User not found!'
          ]
        }, status: :not_found
        return
      end

      render json: {
        name: user.name,
        scores: user.scores.order(played_at: :desc)
      }.to_json
    end

    def login
      user = User.find_by('lower(email) = ?', params[:email])

      if user.blank? || !user.valid_password?(params[:password])
        render json: {
          errors: [
            'Invalid email/password combination'
          ]
        }, status: :unauthorized
        return
      end

      sign_in(:user, user)

      render json: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          token: current_token
        }
      }.to_json
    end

    private

    def current_user?(user)
      user && user == current_user  # OR user&. == current_user
    end

    def correct_user
      user = User.find(params[:id])
      return if current_user?(user)

      render json: {
        errors: [
          'You do not have access!'
        ]
      }, status: :unauthorized
    end
  end
end
