class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false

  # Configure cookie settings to match Rails session store
  # Use the same key as Rails session store for consistency
  session_key "_devhub_session"

  # Disable last_request_at tracking (not needed for API)
  # This prevents Authlogic from calling last_request_update_allowed? on controller
  track_last_request_at false

  # In production, ensure cookies work with cross-origin requests
  if Rails.env.production?
    # Use secure cookies in production (required for same_site: :none)
    secure true
    httponly true
  end
end
