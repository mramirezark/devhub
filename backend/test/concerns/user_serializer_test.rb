# frozen_string_literal: true

require "test_helper"

class UserSerializerTest < ActiveSupport::TestCase
  include UserSerializer

  test "user_payload returns basic user data" do
    user = create(:user, name: "Test User", email: "test@example.com")

    payload = user_payload(user)

    assert_equal user.id, payload[:id]
    assert_equal "Test User", payload[:name]
    assert_equal "test@example.com", payload[:email]
    assert_not payload.key?(:admin)
  end

  test "user_payload includes admin when include_admin is true" do
    admin_user = create(:user, :admin)

    payload = user_payload(admin_user, include_admin: true)

    assert_equal true, payload[:admin]
  end

  test "user_payload excludes admin when include_admin is false" do
    admin_user = create(:user, :admin)

    payload = user_payload(admin_user, include_admin: false)

    assert_not payload.key?(:admin)
  end

  test "user_payload excludes admin by default" do
    admin_user = create(:user, :admin)

    payload = user_payload(admin_user)

    assert_not payload.key?(:admin)
  end

  test "user_payload includes admin false for non-admin users" do
    user = create(:user, admin: false)

    payload = user_payload(user, include_admin: true)

    assert_equal false, payload[:admin]
  end
end
