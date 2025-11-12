class ProfilesController < ApplicationController
  before_action :require_authenticated_user!

  def show
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email
      }
    }
  end
end
