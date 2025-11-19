# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  after_action :set_cookie_with_same_site, only: [ :create ]

  def create
    # Ensure Authlogic has controller context
    UserSession.controller = self

    # Use the simple approach that worked before - let Authlogic handle it
    @user_session = UserSession.new(session_params.to_h)

    if @user_session.save
      render json: { user: user_payload(@user_session.user, include_admin: true) }, status: :created
    else
      render json: { errors: @user_session.errors.full_messages }, status: :unauthorized
    end
  end

  def destroy
    if current_user_session
      current_user_session.destroy
      # Clear the cookie
      response.delete_cookie("_devhub_session", path: "/")
      head :no_content
    else
      head :unauthorized
    end
  end

  private

  def set_cookie_with_same_site
    return unless @user_session&.persisted?

    # Check if cookie was set by Authlogic
    set_cookie_headers = Array(response.headers["Set-Cookie"])
    existing_cookie = set_cookie_headers.find { |h| h.include?("_devhub_session") }

    # Get the cookie value - try from response headers first, then cookie jar
    cookie_value = nil
    if existing_cookie
      # Extract from Set-Cookie header
      match = existing_cookie.match(/^_devhub_session=([^;]+)/)
      cookie_value = match[1] if match
    end

    # Fallback to cookie jar (Authlogic may have set it there)
    cookie_value ||= cookies["_devhub_session"]

    # If still no value, use persistence_token as last resort
    cookie_value ||= @user_session.record&.persistence_token

    return unless cookie_value

    # Check if same_site is already present
    has_same_site = existing_cookie&.match?(/samesite[=:]/i)

    unless has_same_site
      # Set cookie with same_site attribute
      same_site = Rails.env.production? ? :none : :lax

      cookie_hash = {
        value: cookie_value,
        httponly: true,
        secure: Rails.env.production?,
        path: "/",
        same_site: same_site
      }

      if @user_session.remember_me?
        cookie_hash[:expires] = 2.weeks.from_now
      end

      # Remove existing cookie and set with correct attributes
      if existing_cookie
        response.delete_cookie("_devhub_session", path: "/")
      end

      response.set_cookie("_devhub_session", cookie_hash)

      Rails.logger.info "[Authlogic] Cookie set with same_site=#{same_site}, secure=#{cookie_hash[:secure]}"
    end
  end

  def session_params
    permitted = params.require(:session).permit(:email, :password, :remember_me)
    permitted[:remember_me] = ActiveModel::Type::Boolean.new.cast(permitted[:remember_me])
    permitted
  end
end
