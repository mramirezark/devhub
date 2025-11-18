# frozen_string_literal: true

require "test_helper"
require "authlogic/test_case"

class AuthenticationServiceTest < ActiveSupport::TestCase
  include Authlogic::TestCase

  # Authlogic requires a controller context to be activated
  setup :activate_authlogic

  setup do
    @user = create(:user, email: "test@example.com", password: "password123", password_confirmation: "password123")
  end

  test "login succeeds with correct credentials" do
    result = AuthenticationService.login(
      email: "test@example.com",
      password: "password123"
    )

    assert result.user.persisted?
    assert result.user_session.persisted?
    assert_equal @user, result.user
    assert_equal @user, result.user_session.record
    assert_empty result.errors
  end

  test "login succeeds with remember_me option" do
    result = AuthenticationService.login(
      email: "test@example.com",
      password: "password123",
      remember_me: true
    )

    assert result.user.persisted?
    assert result.user_session.persisted?
    assert_empty result.errors
  end

  test "login fails with incorrect password" do
    result = AuthenticationService.login(
      email: "test@example.com",
      password: "wrong_password"
    )

    assert_nil result.user
    assert_nil result.user_session
    assert_not_empty result.errors
  end

  test "login fails with non-existent email" do
    result = AuthenticationService.login(
      email: "nonexistent@example.com",
      password: "password123"
    )

    assert_nil result.user
    assert_nil result.user_session
    assert_not_empty result.errors
  end

  test "login is case-insensitive for email" do
    result = AuthenticationService.login(
      email: "TEST@EXAMPLE.COM",
      password: "password123"
    )

    assert result.user.persisted?
    assert_equal @user, result.user
    assert_empty result.errors
  end

  test "logout destroys session when session exists" do
    user_session = UserSession.create(@user)

    result = AuthenticationService.logout(user_session: user_session)

    assert_nil result.user
    assert_nil result.user_session
    assert_empty result.errors
    # Check that session is no longer persisted
    assert_not user_session.persisted?
  end

  test "logout returns errors when no session exists" do
    result = AuthenticationService.logout(user_session: nil)

    assert_nil result.user
    assert_nil result.user_session
    assert_includes result.errors, "No active session"
  end

  test "logout handles already destroyed session gracefully" do
    user_session = UserSession.create(@user)
    user_session.destroy

    result = AuthenticationService.logout(user_session: user_session)

    assert_nil result.user
    assert_nil result.user_session
    # When session is already destroyed, destroy returns false/nil, but we still return success
    # The service doesn't check if session was already destroyed, it just tries to destroy it
    assert_empty result.errors
  end
end
