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
      # Verify the session cookie was set
      session_cookie = cookies["_devhub_session"]
      Rails.logger.info "[Authlogic] Login successful for user: #{result.user.id}"
      Rails.logger.info "[Authlogic] Session cookie set: #{session_cookie.present?}"
      Rails.logger.info "[Authlogic] Session cookie length: #{session_cookie&.length || 0}"

      # Verify we can read it back immediately
      if session_cookie.present?
        test_session = UserSession.find
        if test_session
          Rails.logger.info "[Authlogic] Session verified - can be read back immediately"
        else
          Rails.logger.error "[Authlogic] WARNING: Session cookie set but cannot be read back!"
        end
      end

      render json: { user: user_payload(result.user) }, status: :created
    else
      Rails.logger.warn "[Authlogic] Login failed: #{result.errors.join(', ')}"
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
