class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      UserSession.create(user)
      render json: { user: user_payload(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
