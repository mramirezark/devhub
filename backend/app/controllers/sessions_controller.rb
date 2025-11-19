# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  def create
    # Ensure Authlogic has controller context
    UserSession.controller = self

    # Use the simple approach that worked before - let Authlogic handle it
    user_session = UserSession.new(session_params.to_h)

    if user_session.save
      render json: { user: user_payload(user_session.user, include_admin: true) }, status: :created
    else
      render json: { errors: user_session.errors.full_messages }, status: :unauthorized
    end
  end

  def destroy
    if current_user_session
      current_user_session.destroy
      head :no_content
    else
      head :unauthorized
    end
  end

  private

  def session_params
    permitted = params.require(:session).permit(:email, :password, :remember_me)
    permitted[:remember_me] = ActiveModel::Type::Boolean.new.cast(permitted[:remember_me])
    permitted
  end
end
