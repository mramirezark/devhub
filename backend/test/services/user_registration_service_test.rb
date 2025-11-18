# frozen_string_literal: true

require "test_helper"
require "authlogic/test_case"

class UserRegistrationServiceTest < ActiveSupport::TestCase
  include Authlogic::TestCase

  # Authlogic requires a controller context to be activated
  setup :activate_authlogic
  test "creates user and session with valid attributes" do
    attributes = {
      name: "New User",
      email: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    }

    result = UserRegistrationService.call(attributes: attributes)

    assert result.user.persisted?
    assert result.user_session.persisted?
    assert_equal "New User", result.user.name
    assert_equal "newuser@example.com", result.user.email
    assert_equal result.user, result.user_session.record
    assert_empty result.errors
  end

  test "returns errors when user is invalid" do
    attributes = {
      name: nil,
      email: "invalid-email",
      password: "short",
      password_confirmation: "different"
    }

    result = UserRegistrationService.call(attributes: attributes)

    assert_nil result.user
    assert_nil result.user_session
    assert_not_empty result.errors
    assert_includes result.errors.join(" "), "can't be blank"
  end

  test "returns errors when email is already taken" do
    create(:user, email: "existing@example.com")

    attributes = {
      name: "Another User",
      email: "existing@example.com",
      password: "password123",
      password_confirmation: "password123"
    }

    result = UserRegistrationService.call(attributes: attributes)

    assert_nil result.user
    assert_nil result.user_session
    assert_not_empty result.errors
    assert_includes result.errors.join(" "), "has already been taken"
  end

  test "filters out non-permitted attributes" do
    attributes = {
      name: "New User",
      email: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true,
      created_at: Time.current,
      id: 999
    }

    result = UserRegistrationService.call(attributes: attributes)

    assert result.user.persisted?
    assert_not result.user.admin?
    assert_not_equal 999, result.user.id
  end

  test "normalizes email to lowercase" do
    attributes = {
      name: "New User",
      email: "NEWUSER@EXAMPLE.COM",
      password: "password123",
      password_confirmation: "password123"
    }

    result = UserRegistrationService.call(attributes: attributes)

    assert result.user.persisted?
    assert_equal "newuser@example.com", result.user.email
  end
end
