# frozen_string_literal: true

require "test_helper"
require "authlogic/test_case"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Authlogic::TestCase

  setup :activate_authlogic

  setup do
    @user = create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
  end

  test "POST /session creates a session with valid credentials" do
    session_params = {
      session: {
        email: "test@example.com",
        password: "Password123"
      }
    }

    assert_difference -> { User.count } => 0 do
      post session_path, params: session_params, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @user.id, json_response["user"]["id"]
    assert_equal @user.name, json_response["user"]["name"]
    assert_equal @user.email, json_response["user"]["email"]
    # Verify JWT tokens are returned
    assert_not_nil json_response["access_token"]
    assert_not_nil json_response["refresh_token"]
  end

  test "POST /session creates a session with remember_me option" do
    session_params = {
      session: {
        email: "test@example.com",
        password: "Password123",
        remember_me: true
      }
    }

    post session_path, params: session_params, as: :json

    assert_response :created
  end

  test "POST /session returns unauthorized with invalid password" do
    session_params = {
      session: {
        email: "test@example.com",
        password: "WrongPassword123"
      }
    }

    post session_path, params: session_params, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
  end

  test "POST /session returns unauthorized with non-existent email" do
    session_params = {
      session: {
        email: "nonexistent@example.com",
        password: "Password123"
      }
    }

    post session_path, params: session_params, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
  end

  test "POST /session is case-insensitive for email" do
    session_params = {
      session: {
        email: "TEST@EXAMPLE.COM",
        password: "Password123"
      }
    }

    post session_path, params: session_params, as: :json

    assert_response :created
  end

  test "DELETE /session destroys the current session" do
    # Create session by logging in first
    post session_path, params: { session: { email: "test@example.com", password: "Password123" } }, as: :json
    assert_response :created

    delete session_path

    assert_response :no_content
  end

  test "DELETE /session returns no_content when no session exists" do
    # JWT tokens are stateless, so logout always succeeds (client-side token removal)
    # Cookie-based sessions would require authentication, but we accept logout without auth
    delete session_path

    assert_response :no_content
  end
end
