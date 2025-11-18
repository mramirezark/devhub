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
      session = UserSession.find
      session
    rescue StandardError => e
      Rails.logger.error "UserSession.find failed: #{e.message}"
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
