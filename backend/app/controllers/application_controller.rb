class ApplicationController < ActionController::API
  include ActionController::Cookies

  # Make cookies accessible to Authlogic
  # Authlogic needs to access cookies, but in API controllers it's private by default
  # By defining it as a public method, Authlogic can access it
  public :cookies

  # ============================================================================
  # Authlogic Controller Method Stubs
  # ============================================================================
  # ActionController::API doesn't include all methods that Authlogic expects.
  # These explicit stubs provide the necessary methods with sensible defaults
  # for API usage. If Authlogic calls a method not listed here, it will raise
  # a proper NoMethodError so we can add it explicitly.
  # ============================================================================

  # Session ID renewal - allow by default (standard behavior)
  def renew_session_id
    true
  end

  # Last request tracking - disable for API controllers (not needed for stateless APIs)
  def last_request_update_allowed?
    false
  end

  # Cookie domain - return nil to use request's default domain
  def cookie_domain
    nil
  end

  # Cookie path - return nil to use default path (/)
  def cookie_path
    nil
  end

  # Cookie secure flag - must match Rails session store
  def cookie_secure
    Rails.env.production?
  end

  # Cookie http_only flag - must match Rails session store
  def cookie_http_only
    true
  end

  # Session access - provide access to the session object
  # ActionController::API doesn't include session by default, so we provide it
  def session
    request.session
  end

  # Handle unverified requests (CSRF) - raise exception for API
  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken
  end

  private

  def current_user_session
    # Activate Authlogic for this controller before finding session
    # Authlogic needs the controller to access cookies and session data
    UserSession.controller = self unless UserSession.controller == self

    @current_user_session ||= begin
      # Check all cookies to see what's available
      all_cookies = cookies.to_h.keys
      session_cookie = cookies["_devhub_session"]

      Rails.logger.info "[Authlogic] Looking for session. Available cookies: #{all_cookies.inspect}"
      Rails.logger.info "[Authlogic] Session cookie present: #{session_cookie.present?}"
      Rails.logger.info "[Authlogic] Session cookie value length: #{session_cookie&.length || 0}"

      if session_cookie.present?
        Rails.logger.info "[Authlogic] Session cookie preview: #{session_cookie[0..50]}..."
      end

      session = UserSession.find

      if session
        Rails.logger.info "[Authlogic] Session found for user: #{session.user&.id}"
      elsif session_cookie.present?
        Rails.logger.error "[Authlogic] Session cookie exists but UserSession.find returned nil"
        Rails.logger.error "[Authlogic] This suggests Authlogic cannot read the cookie. Check cookie attributes."
      else
        Rails.logger.warn "[Authlogic] No session cookie found"
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
