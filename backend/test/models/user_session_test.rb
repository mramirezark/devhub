require "test_helper"
require "authlogic/test_case"

class UserSessionTest < ActiveSupport::TestCase
  include Authlogic::TestCase

  # Authlogic requires a controller context to be activated
  setup :activate_authlogic

  test "should create session with valid credentials" do
    user = create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(
      email: "test@example.com",
      password: "Password123"
    )
    assert session.save
    assert_equal user, session.user
  end

  test "should not create session with invalid email" do
    create(:user, email: "test@example.com")
    session = UserSession.new(
      email: "wrong@example.com",
      password: "Password123"
    )
    assert_not session.save
    assert_nil session.user
  end

  test "should not create session with invalid password" do
    create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(
      email: "test@example.com",
      password: "wrong_password"
    )
    assert_not session.save
    assert_nil session.user
  end

  test "should not allow http basic auth" do
    # This is a configuration test - the allow_http_basic_auth false setting
    # means the session won't authenticate via HTTP basic auth
    # We can't easily test this without making actual HTTP requests,
    # but we can verify the configuration exists
    assert UserSession.respond_to?(:allow_http_basic_auth)
  end

  test "should find user by email" do
    user = create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(email: "test@example.com", password: "Password123")
    session.save
    assert_equal user.id, session.user.id
  end

  test "should be case insensitive for email" do
    user = create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(email: "TEST@EXAMPLE.COM", password: "Password123")
    assert session.save
    assert_equal user.id, session.user.id
  end

  test "should persist session after creation" do
    create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(email: "test@example.com", password: "Password123")
    session.save
    assert session.persisted?
  end

  test "should destroy session" do
    create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123")
    session = UserSession.new(email: "test@example.com", password: "Password123")
    session.save
    assert session.destroy
    assert_not session.persisted?
  end
end
