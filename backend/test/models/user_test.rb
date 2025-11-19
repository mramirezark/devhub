require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = build(:user)
    assert user.valid?
  end

  test "should require name" do
    user = build(:user, name: nil)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    create(:user, email: "test@example.com")
    duplicate_user = build(:user, email: "TEST@EXAMPLE.COM")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should normalize email to lowercase" do
    user = build(:user, email: "  TEST@EXAMPLE.COM  ")
    user.valid?
    assert_equal "test@example.com", user.email
  end

  test "should strip whitespace from email" do
    user = build(:user, email: "  test@example.com  ")
    user.valid?
    assert_equal "test@example.com", user.email
  end

  test "should validate password confirmation matches password" do
    user = build(:user, password_confirmation: "different_password")
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "does not match password"
  end

  test "should not require password confirmation when password is blank" do
    existing_user = create(:user)
    existing_user.password = nil
    existing_user.password_confirmation = nil
    assert existing_user.valid?
  end

  test "should have many assigned_tasks" do
    user = create(:user)
    project = create(:project)
    task = create(:task, project: project, assignee: user)

    assert_includes user.assigned_tasks, task
  end

  test "should nullify assigned_tasks when user is destroyed" do
    user = create(:user)
    task = create(:task, assignee: user)

    user.destroy
    task.reload
    assert_nil task.assignee
  end

  test "should sync password_digest from crypted_password" do
    user = create(:user)
    assert_not_nil user.password_digest
    assert_equal user.crypted_password, user.password_digest
  end

  test "should authenticate with correct password" do
    user = create(:user, password: "SecurePass123", password_confirmation: "SecurePass123")
    assert user.valid_password?("SecurePass123")
  end

  test "should not authenticate with incorrect password" do
    user = create(:user, password: "SecurePass123", password_confirmation: "SecurePass123")
    assert_not user.valid_password?("WrongPassword123")
  end

  test "should have admin flag" do
    user = create(:user, :admin)
    assert user.admin?
  end

  test "should create user with assigned tasks trait" do
    user = create(:user, :with_assigned_tasks)
    assert_equal 3, user.assigned_tasks.count
  end
end
