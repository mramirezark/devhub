# frozen_string_literal: true

require "test_helper"

module Admin
  module Services
    class UserServiceTest < ActiveSupport::TestCase
      test "list returns all users ordered by created_at desc" do
        user1 = create(:user, created_at: 2.days.ago)
        user2 = create(:user, created_at: 1.day.ago)
        user3 = create(:user, created_at: Time.current)

        users = UserService.list

        assert_equal [ user3, user2, user1 ].map(&:id), users.map(&:id)
      end

      test "find returns user by id" do
        user = create(:user)

        found_user = UserService.find(user.id)

        assert_equal user, found_user
      end

      test "find returns nil for non-existent user" do
        found_user = UserService.find(99999)

        assert_nil found_user
      end

      test "create creates a new user" do
        result = UserService.create(
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: false
        )

        assert result[:success]
        assert_not_nil result[:user]
        assert_equal "New User", result[:user].name
        assert_equal "newuser@example.com", result[:user].email
        assert_not result[:user].admin?
        assert_empty result[:errors]
      end

      test "create creates admin user when admin is true" do
        result = UserService.create(
          name: "Admin User",
          email: "admin@example.com",
          password: "password123",
          admin: true
        )

        assert result[:success]
        assert result[:user].admin?
      end

      test "create uses password as password_confirmation when not provided" do
        result = UserService.create(
          name: "New User",
          email: "newuser@example.com",
          password: "password123"
        )

        assert result[:success]
        assert result[:user].persisted?
      end

      test "create returns errors when user is invalid" do
        result = UserService.create(
          name: nil,
          email: "invalid-email",
          password: "short"
        )

        assert_not result[:success]
        assert_nil result[:user]
        assert_not_empty result[:errors]
      end

      test "update updates user attributes" do
        user = create(:user, name: "Old Name", admin: false)

        result = UserService.update(
          id: user.id,
          name: "New Name",
          admin: true
        )

        assert result[:success]
        assert_equal "New Name", user.reload.name
        assert user.admin?
        assert_empty result[:errors]
      end

      test "update returns success with no changes when no attributes provided" do
        user = create(:user, name: "Original Name")

        result = UserService.update(id: user.id)

        assert result[:success]
        assert_equal "Original Name", user.reload.name
        assert_empty result[:errors]
      end

      test "update returns error when user not found" do
        result = UserService.update(id: 99999, name: "New Name")

        assert_not result[:success]
        assert_includes result[:errors], "User not found"
      end

      test "update returns errors when user is invalid" do
        user = create(:user)
        create(:user, email: "existing@example.com")

        result = UserService.update(id: user.id, email: "existing@example.com")

        assert_not result[:success]
        assert_not_empty result[:errors]
      end

      test "delete destroys user" do
        user = create(:user)

        result = UserService.delete(id: user.id, current_user_id: create(:user).id)

        assert result[:success]
        assert_empty result[:errors]
        assert_raises(ActiveRecord::RecordNotFound) { user.reload }
      end

      test "delete returns error when user not found" do
        result = UserService.delete(id: 99999, current_user_id: create(:user).id)

        assert_not result[:success]
        assert_includes result[:errors], "User not found"
      end

      test "delete prevents deleting own account" do
        user = create(:user)

        result = UserService.delete(id: user.id, current_user_id: user.id)

        assert_not result[:success]
        assert_includes result[:errors], "You cannot delete your own account"
        assert user.reload.persisted?
      end

      test "promote sets user admin to true" do
        user = create(:user, admin: false)

        result = UserService.promote(id: user.id)

        assert result[:success]
        assert user.reload.admin?
        assert_empty result[:errors]
      end

      test "promote returns error when user not found" do
        result = UserService.promote(id: 99999)

        assert_not result[:success]
        assert_includes result[:errors], "User not found"
      end

      test "demote sets user admin to false" do
        user = create(:user, :admin)

        result = UserService.demote(id: user.id, current_user_id: create(:user).id)

        assert result[:success]
        assert_not user.reload.admin?
        assert_empty result[:errors]
      end

      test "demote returns error when user not found" do
        result = UserService.demote(id: 99999, current_user_id: create(:user).id)

        assert_not result[:success]
        assert_includes result[:errors], "User not found"
      end

      test "demote prevents demoting yourself" do
        user = create(:user, :admin)

        result = UserService.demote(id: user.id, current_user_id: user.id)

        assert_not result[:success]
        assert_includes result[:errors], "You cannot demote yourself"
        assert user.reload.admin?
      end
    end
  end
end
