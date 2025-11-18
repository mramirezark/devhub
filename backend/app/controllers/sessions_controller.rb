# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  def create
    # Ensure Authlogic has controller context before login
    UserSession.controller = self

    result = AuthenticationService.login(
      email: session_params[:email],
      password: session_params[:password],
      remember_me: session_params[:remember_me]
    )

    if result.user
      render json: { user: user_payload(result.user) }, status: :created
    else
      render json: { errors: result.errors }, status: :unauthorized
    end
  end

  def destroy
    result = AuthenticationService.logout(user_session: current_user_session)

    if result.errors.empty?
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
