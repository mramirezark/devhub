class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false

  # Configure cookie settings to match Rails session store exactly
  # Use the same key as Rails session store for consistency
  session_key "_devhub_session"

  # Cookie security settings (must match Rails session store configuration)
  # These settings ensure cookies work with cross-origin requests in production
  secure Rails.env.production?
  httponly true

  # Configure cookie to persist across requests
  # In production with cross-origin, we need to ensure cookies are sent
  # The controller's cookie_domain, cookie_path, and cookie_secure methods
  # will be used to set these attributes
end
