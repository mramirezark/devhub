# frozen_string_literal: true

require "test_helper"
require "authlogic/test_case"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Authlogic::TestCase

  setup :activate_authlogic
  test "GET /profile returns current user data when authenticated" do
    user = create(:user, name: "Test User", email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    # Create session by logging in
    post session_path, params: { session: { email: "test@example.com", password: "Password123" } }, as: :json

    get profile_path

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal user.id, json_response["user"]["id"]
    assert_equal "Test User", json_response["user"]["name"]
    assert_equal "test@example.com", json_response["user"]["email"]
    assert_equal false, json_response["user"]["admin"]
  end

  test "GET /profile includes admin status when user is admin" do
    admin_user = create(:user, :admin, name: "Admin User", email: "adminuser@example.com", password: "Password123", password_confirmation: "Password123")
    # Create session by logging in
    post session_path, params: { session: { email: "adminuser@example.com", password: "Password123" } }, as: :json

    get profile_path

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal admin_user.id, json_response["user"]["id"]
    assert_equal true, json_response["user"]["admin"]
  end

  test "GET /profile returns unauthorized when not authenticated" do
    get profile_path

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized", json_response["error"]
  end
end
