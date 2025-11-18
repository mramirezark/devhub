class ApplicationController < ActionController::API
  include ActionController::Cookies

  # Make cookies accessible to Authlogic
  # Authlogic needs to access cookies, but in API controllers it's private by default
  # By defining it as a public method, Authlogic can access it
  public :cookies

  # Stub methods for Authlogic features not available in API controllers
  # Authlogic calls these to determine if it should update session tracking
  # We return false/true as appropriate to disable these features in API controllers
  def last_request_update_allowed?
    false
  end

  def renew_session_id
    # Allow session ID renewal (default behavior)
    true
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
