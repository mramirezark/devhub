# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "POST /users creates a new user and returns user data" do
    user_params = {
      user: {
        name: "New User",
        email: "newuser@example.com",
        password: "Password123",
        password_confirmation: "Password123"
      }
    }

    assert_difference -> { User.count } => 1 do
      post users_path, params: user_params, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New User", json_response["user"]["name"]
    assert_equal "newuser@example.com", json_response["user"]["email"]
    assert json_response["user"]["id"].present?

    # Verify user was created
    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user
  end

  test "POST /users returns errors when user is invalid" do
    user_params = {
      user: {
        name: nil,
        email: "invalid-email",
        password: "short",
        password_confirmation: "different"
      }
    }

    assert_no_difference -> { User.count } do
      post users_path, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
  end

  test "POST /users returns errors when email is already taken" do
    create(:user, email: "existing@example.com")

    user_params = {
      user: {
        name: "Another User",
        email: "existing@example.com",
        password: "Password123",
        password_confirmation: "Password123"
      }
    }

    assert_no_difference -> { User.count } do
      post users_path, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
    assert_includes json_response["errors"].join(" "), "has already been taken"
  end

  test "POST /users filters out non-permitted parameters" do
    user_params = {
      user: {
        name: "New User",
        email: "newuser@example.com",
        password: "Password123",
        password_confirmation: "Password123",
        admin: true
      }
    }

    post users_path, params: user_params, as: :json

    assert_response :created
    user = User.find_by(email: "newuser@example.com")
    assert_not user.admin?
  end
end
