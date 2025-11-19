# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Cookies

  # Make cookies accessible to Authlogic (needed for ActionController::API)
  public :cookies

  # Stub methods that Authlogic expects (minimal set that worked before)
  def renew_session_id
    true
  end

  def last_request_update_allowed?
    false
  end

  def cookie_domain
    nil
  end

  def cookie_path
    nil
  end

  def cookie_secure
    Rails.env.production?
  end

  def cookie_http_only
    true
  end

  def session
    request.session
  end

  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken
  end

  private

  def current_user_session
    UserSession.controller = self unless UserSession.controller == self

    @current_user_session ||= begin
      session_cookie = cookies["_devhub_session"]
      all_cookies = cookies.to_h.keys

      Rails.logger.info "[Authlogic] Looking for session. Available cookies: #{all_cookies.inspect}"
      Rails.logger.info "[Authlogic] Session cookie present: #{session_cookie.present?}"
      Rails.logger.info "[Authlogic] Session cookie value length: #{session_cookie&.length || 0}"

      session = UserSession.find

      if session
        Rails.logger.info "[Authlogic] Session found for user: #{session.user&.id}"
      else
        Rails.logger.warn "[Authlogic] No session found. Cookie present: #{session_cookie.present?}"
        if session_cookie.present?
          Rails.logger.warn "[Authlogic] Cookie exists but UserSession.find returned nil - cookie may be invalid"
        end
      end

      session
    rescue StandardError => e
      Rails.logger.error "[Authlogic] UserSession.find failed: #{e.class}: #{e.message}"
      Rails.logger.error "[Authlogic] Backtrace: #{e.backtrace.first(5).join("\n")}"
      nil
    end
  end

  def current_user
    @current_user ||= current_user_session&.record
  end

  def require_authenticated_user!
    return if current_user.present?

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
