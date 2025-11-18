# frozen_string_literal: true

class UsersController < ApplicationController
  include UserSerializer

  def create
    result = UserRegistrationService.call(attributes: user_params)

    if result.user
      render json: { user: user_payload(result.user) }, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
