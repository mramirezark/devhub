class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false

  # Configure cookie settings to match Rails session store
  # Use the same key as Rails session store for consistency
  session_key "_devhub_session"

  # Cookie security settings (must match Rails session store configuration)
  # secure and httponly are set based on environment in config/application.rb
  secure Rails.env.production?
  httponly true
end
