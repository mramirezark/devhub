# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false

  # Use the same session key as Rails session store
  session_key "_devhub_session"

  # Cookie settings - these will be used by Authlogic
  secure Rails.env.production?
  httponly true
end
