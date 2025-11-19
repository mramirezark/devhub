# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  after_action :ensure_cookie_attributes, only: [ :create ]

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
      head :no_content
    else
      head :unauthorized
    end
  end

  private

  def ensure_cookie_attributes
    return unless @user_session&.persisted?

    # Check what Authlogic set in the response headers
    set_cookie_headers = Array(response.headers["Set-Cookie"])
    devhub_cookie_header = set_cookie_headers.find { |h| h.include?("_devhub_session") }

    # Extract cookie value from the header if present
    cookie_value = nil
    if devhub_cookie_header
      # Extract value from Set-Cookie header: "_devhub_session=VALUE; ..."
      match = devhub_cookie_header.match(/^_devhub_session=([^;]+)/)
      cookie_value = match[1] if match
    end

    # Fallback to cookie jar if not in headers yet
    cookie_value ||= cookies["_devhub_session"]
    return unless cookie_value

    # Check if same_site is already present in the header
    has_same_site = devhub_cookie_header&.match?(/samesite[=:]/i)

    if !has_same_site || !devhub_cookie_header
      # Authlogic set the cookie but it's missing same_site, update it
      same_site = Rails.env.production? ? :none : :lax

      cookie_hash = {
        value: cookie_value, # Use the value Authlogic set
        httponly: true,
        secure: Rails.env.production?,
        path: "/",
        same_site: same_site
      }

      if @user_session.remember_me?
        cookie_hash[:expires] = 2.weeks.from_now
      end

      # Delete existing cookie if present, then set with correct attributes
      if devhub_cookie_header
        response.delete_cookie("_devhub_session", path: "/")
      end
      response.set_cookie("_devhub_session", cookie_hash)

      Rails.logger.info "[Authlogic] Cookie set/updated with same_site=#{same_site}, secure=#{cookie_hash[:secure]}"
    else
      Rails.logger.info "[Authlogic] Cookie already has same_site attribute"
    end
  end

  def session_params
    permitted = params.require(:session).permit(:email, :password, :remember_me)
    permitted[:remember_me] = ActiveModel::Type::Boolean.new.cast(permitted[:remember_me])
    permitted
  end
end
