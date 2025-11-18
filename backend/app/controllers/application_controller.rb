class ApplicationController < ActionController::API
  include ActionController::Cookies

  # Make cookies accessible to Authlogic
  # Authlogic needs to access cookies, but in API controllers it's private by default
  # By defining it as a public method, Authlogic can access it
  public :cookies

  private

  def current_user_session
    # Activate Authlogic for this controller before finding session
    # Authlogic needs the controller to access cookies and session data
    UserSession.controller = self unless UserSession.controller == self
    @current_user_session ||= begin
      session = UserSession.find
      # Log in production for debugging
      if Rails.env.production?
        if session
          Rails.logger.info "UserSession found for user: #{session.user&.id}"
        else
          # Check if session cookie exists
          session_cookie = cookies["_devhub_session"]
          Rails.logger.warn "UserSession.find returned nil. Session cookie present: #{session_cookie.present?}"
        end
      end
      session
    rescue StandardError => e
      # Log error in production for debugging
      Rails.logger.error "UserSession.find failed: #{e.message}" if Rails.env.production?
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
