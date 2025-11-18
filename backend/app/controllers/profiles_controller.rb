# frozen_string_literal: true

class ProfilesController < ApplicationController
  include UserSerializer

  before_action :require_authenticated_user!

  def show
    render json: {
      user: user_payload(current_user, include_admin: true)
    }
  end
end
