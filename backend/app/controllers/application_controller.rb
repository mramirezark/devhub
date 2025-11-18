class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def current_user_session
    # Activate Authlogic for this controller before finding session
    # Authlogic needs the controller to access cookies and session data
    UserSession.controller = self unless UserSession.controller == self
    @current_user_session ||= begin
      UserSession.find
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
