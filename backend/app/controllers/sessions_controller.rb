# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  after_action :set_cookie_with_same_site, only: [ :create ]

  def create
    # Ensure Authlogic has controller context
    UserSession.controller = self

    # Use Authlogic to validate credentials
    @user_session = UserSession.new(session_params.to_h)

    if @user_session.save
      user = @user_session.user

      # Generate JWT tokens after successful Authlogic login
      access_token = JwtService.encode_access_token(
        user_id: user.id,
        email: user.email
      )
      refresh_token = JwtService.encode_refresh_token(user_id: user.id)

      render json: {
        user: user_payload(user, include_admin: true),
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { errors: @user_session.errors.full_messages }, status: :unauthorized
    end
  end

  def refresh
    refresh_token = params[:refresh_token]
    return render json: { error: "Refresh token required" }, status: :unauthorized unless refresh_token

    token_data = JwtService.verify_refresh_token(refresh_token)
    return render json: { error: "Invalid or expired refresh token" }, status: :unauthorized unless token_data

    user = User.find_by(id: token_data[:user_id])
    return render json: { error: "User not found" }, status: :unauthorized unless user

    # Generate new access and refresh tokens
    new_access_token = JwtService.encode_access_token(
      user_id: user.id,
      email: user.email
    )
    new_refresh_token = JwtService.encode_refresh_token(user_id: user.id)

    render json: {
      access_token: new_access_token,
      refresh_token: new_refresh_token
    }, status: :ok
  end

  def destroy
    # For JWT tokens, they are stateless so we just clear the session/cookie
    # Client is responsible for discarding tokens (logout is handled client-side)
    if current_user_session
      current_user_session.destroy
      # Clear the cookie
      response.delete_cookie("_devhub_session", path: "/")
    end

    # JWT tokens don't need server-side invalidation (stateless)
    # If you need token revocation, implement a blacklist/whitelist
    head :no_content
  end

  private

  def set_cookie_with_same_site
    return unless @user_session&.persisted?

    # Check if cookie was set by Authlogic
    set_cookie_header = response.headers["Set-Cookie"]
    set_cookie_headers = if set_cookie_header.is_a?(Array)
      set_cookie_header
    elsif set_cookie_header.is_a?(String)
      [ set_cookie_header ]
    else
      []
    end

    existing_cookie_index = set_cookie_headers.index { |h| h.include?("_devhub_session") }
    existing_cookie = existing_cookie_index ? set_cookie_headers[existing_cookie_index] : nil

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

    # Extract attributes from existing cookie if present
    domain = nil
    path = "/"
    expires = nil
    secure_flag = false

    if existing_cookie
      domain_match = existing_cookie.match(/domain=([^;]+)/i)
      domain = domain_match[1].strip if domain_match

      path_match = existing_cookie.match(/path=([^;]+)/i)
      path = path_match[1].strip if path_match

      expires_match = existing_cookie.match(/expires=([^;]+)/i)
      expires_str = expires_match[1].strip if expires_match
      expires = Time.parse(expires_str) if expires_str rescue nil

      secure_flag = existing_cookie.match?(/secure/i)
    end

    # Check if same_site is already present and attributes match
    has_same_site = existing_cookie&.match?(/samesite[=:]/i)
    same_site_value = if has_same_site
      match = existing_cookie.match(/samesite[=:](\w+)/i)
      match[1].downcase.to_sym if match
    end

    same_site = Rails.env.production? ? :none : :lax
    secure = Rails.env.production?

    # Only update if same_site is missing or different, or if secure flag doesn't match
    needs_update = !has_same_site || same_site_value != same_site ||
                   (secure && !secure_flag)

    if needs_update
      cookie_hash = {
        value: cookie_value,
        httponly: true,
        secure: secure,
        path: path,
        same_site: same_site
      }

      # Include domain if it was set originally
      cookie_hash[:domain] = domain if domain

      # Set expires if remember_me is enabled
      if @user_session.remember_me?
        cookie_hash[:expires] = 2.weeks.from_now
      elsif expires
        # Preserve existing expires if not using remember_me
        cookie_hash[:expires] = expires
      end

      # Remove the old cookie header if it exists to avoid duplicate Set-Cookie headers
      if existing_cookie_index
        set_cookie_headers.delete_at(existing_cookie_index)
        if set_cookie_headers.empty?
          response.headers.delete("Set-Cookie")
        elsif set_cookie_headers.length == 1
          response.headers["Set-Cookie"] = set_cookie_headers.first
        else
          response.headers["Set-Cookie"] = set_cookie_headers
        end
      end

      # Delete existing cookie - try both with and without domain to ensure clean removal
      # This is important because browsers treat cookies with and without domain differently
      delete_options = { path: path }
      response.delete_cookie("_devhub_session", delete_options)
      if domain
        delete_options[:domain] = domain
        response.delete_cookie("_devhub_session", delete_options)
      end

      # Set the new cookie with correct attributes
      response.set_cookie("_devhub_session", cookie_hash)

      Rails.logger.info "[Authlogic] Cookie set with same_site=#{same_site}, secure=#{secure}, domain=#{domain || 'nil'}, path=#{path}"
    end
  end

  def session_params
    permitted = params.require(:session).permit(:email, :password, :remember_me)
    permitted[:remember_me] = ActiveModel::Type::Boolean.new.cast(permitted[:remember_me])
    permitted
  end
end
