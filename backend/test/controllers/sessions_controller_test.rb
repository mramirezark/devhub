# frozen_string_literal: true

require "test_helper"
require "authlogic/test_case"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Authlogic::TestCase

  setup :activate_authlogic

  setup do
    @user = create(:user, email: "test@example.com", password: "password123", password_confirmation: "password123")
  end

  test "POST /session creates a session with valid credentials" do
    session_params = {
      session: {
        email: "test@example.com",
        password: "password123"
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
  end

  test "POST /session creates a session with remember_me option" do
    session_params = {
      session: {
        email: "test@example.com",
        password: "password123",
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
        password: "wrong_password"
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
        password: "password123"
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
        password: "password123"
      }
    }

    post session_path, params: session_params, as: :json

    assert_response :created
  end

  test "DELETE /session destroys the current session" do
    # Create session by logging in first
    post session_path, params: { session: { email: "test@example.com", password: "password123" } }, as: :json
    assert_response :created

    delete session_path

    assert_response :no_content
  end

  test "DELETE /session returns unauthorized when no session exists" do
    delete session_path

    assert_response :unauthorized
  end
end
