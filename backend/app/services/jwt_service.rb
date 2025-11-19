# frozen_string_literal: true

class JwtService
  # JWT secret key - use Rails credentials or ENV variable
  SECRET_KEY = ENV.fetch("JWT_SECRET_KEY") do
    Rails.application.credentials.dig(:jwt, :secret_key) ||
      Rails.application.secret_key_base
  end.freeze

  # Access token expiration (15 minutes)
  ACCESS_TOKEN_EXPIRATION = 15.minutes

  # Refresh token expiration (30 days)
  REFRESH_TOKEN_EXPIRATION = 30.days

  class << self
    # Generate access token (short-lived, for API requests)
    def encode_access_token(user_id:, email:)
      payload = {
        user_id: user_id,
        email: email,
        type: "access",
        exp: ACCESS_TOKEN_EXPIRATION.from_now.to_i,
        iat: Time.now.to_i
      }
      JWT.encode(payload, SECRET_KEY, "HS256")
    end

    # Generate refresh token (long-lived, for getting new access tokens)
    def encode_refresh_token(user_id:)
      payload = {
        user_id: user_id,
        type: "refresh",
        exp: REFRESH_TOKEN_EXPIRATION.from_now.to_i,
        iat: Time.now.to_i
      }
      JWT.encode(payload, SECRET_KEY, "HS256")
    end

    # Decode and verify JWT token
    def decode_token(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
      decoded[0] # Return payload (first element)
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIatError => e
      Rails.logger.warn "[JWT] Token decode failed: #{e.class}: #{e.message}"
      nil
    end

    # Verify access token and extract user info
    def verify_access_token(token)
      payload = decode_token(token)
      return nil unless payload
      return nil unless payload["type"] == "access"

      {
        user_id: payload["user_id"],
        email: payload["email"]
      }
    end

    # Verify refresh token
    def verify_refresh_token(token)
      payload = decode_token(token)
      return nil unless payload
      return nil unless payload["type"] == "refresh"

      {
        user_id: payload["user_id"]
      }
    end
  end
end
