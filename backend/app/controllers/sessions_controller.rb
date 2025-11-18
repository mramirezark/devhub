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
      Rails.logger.info "[Authlogic] Login successful for user: #{result.user.id}"
      Rails.logger.info "[Authlogic] UserSession persisted: #{result.user_session.persisted?}"

      # Authlogic's automatic cookie setting doesn't work properly with ActionController::API
      # We need to manually set the cookie with the correct attributes
      # Authlogic identifies sessions using the user's persistence_token
      user = result.user_session.record

      if user && user.respond_to?(:persistence_token)
        persistence_token = user.persistence_token
        same_site = Rails.env.production? ? :none : :lax

        # Set the cookie with all required attributes for cross-origin support
        cookie_options = {
          value: persistence_token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: same_site
        }

        # Add expires if remember_me is set
        if result.user_session.remember_me?
          cookie_options[:expires] = 2.weeks.from_now
        end

        # Set the cookie via Rails cookie helper
        cookies["_devhub_session"] = cookie_options

        Rails.logger.info "[Authlogic] Cookie set with persistence_token"
        Rails.logger.info "[Authlogic] Cookie attributes: httponly=true, secure=#{Rails.env.production?}, same_site=#{same_site}"

        # Check if cookie is in the cookie jar
        cookie_jar_value = cookies["_devhub_session"]
        Rails.logger.info "[Authlogic] Cookie in jar: #{cookie_jar_value.present?}, value length: #{cookie_jar_value&.length || 0}"

        # Try a different approach - set cookie directly via response
        # Sometimes ActionController::API needs explicit cookie setting
        # response.set_cookie uses Rack::Utils.set_cookie_header format
        response.set_cookie(
          "_devhub_session",
          {
            value: persistence_token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: same_site,  # :none or :lax symbol
            expires: result.user_session.remember_me? ? 2.weeks.from_now : nil,
            path: "/"
          }
        )

        Rails.logger.info "[Authlogic] Cookie also set via response.set_cookie"

        # Verify the cookie was actually set in the response
        # Check after setting via response.set_cookie
        set_cookie_headers = Array(response.headers["Set-Cookie"])
        devhub_cookie = set_cookie_headers.find { |h| h.include?("_devhub_session") }

        if devhub_cookie
          Rails.logger.info "[Authlogic] ✓ Set-Cookie header found: #{devhub_cookie[0..300]}"
          # Check if same_site is in the header
          if devhub_cookie.include?("SameSite=None")
            Rails.logger.info "[Authlogic] ✓ SameSite=None is in Set-Cookie header"
          else
            Rails.logger.warn "[Authlogic] ⚠ SameSite=None NOT found in Set-Cookie header"
          end
          if devhub_cookie.include?("Secure")
            Rails.logger.info "[Authlogic] ✓ Secure is in Set-Cookie header"
          else
            Rails.logger.warn "[Authlogic] ⚠ Secure NOT found in Set-Cookie header"
          end
        else
          Rails.logger.error "[Authlogic] ✗ Set-Cookie header for _devhub_session NOT found in response"
          Rails.logger.error "[Authlogic] Available Set-Cookie headers: #{set_cookie_headers.inspect}"
        end
      else
        Rails.logger.error "[Authlogic] Cannot set cookie - user or persistence_token missing"
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
