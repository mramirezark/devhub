# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreateUser, type: :graphql do
  let(:admin_user) { User.create!(name: "Admin", email: "admin@example.com", password: "password123", password_confirmation: "password123", admin: true) }
  let(:regular_user) { User.create!(name: "Regular User", email: "user@example.com", password: "password123", password_confirmation: "password123", admin: false) }
  let(:admin_context) { { current_user: admin_user, current_user_session: nil } }
  let(:regular_context) { { current_user: regular_user, current_user_session: nil } }

  describe "#resolve" do
    let(:mutation) do
      <<~GRAPHQL
        mutation CreateUser($name: String!, $email: String!, $password: String!, $passwordConfirmation: String, $admin: Boolean) {
          createUser(
            name: $name
            email: $email
            password: $password
            passwordConfirmation: $passwordConfirmation
            admin: $admin
          ) {
            user {
              id
              name
              email
              admin
            }
            errors
          }
        }
      GRAPHQL
    end

    it "creates a user successfully for admin" do
      variables = {
        name: "New User",
        email: "newuser@example.com",
        password: "password123",
        passwordConfirmation: "password123",
        admin: false
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createUser"]["errors"]).to eq([])
      expect(result["data"]["createUser"]["user"]).not_to be_nil
      expect(result["data"]["createUser"]["user"]["name"]).to eq("New User")
      expect(result["data"]["createUser"]["user"]["email"]).to eq("newuser@example.com")
      expect(result["data"]["createUser"]["user"]["admin"]).to eq(false)

      user = User.find_by(email: "newuser@example.com")
      expect(user).not_to be_nil
      expect(user.name).to eq("New User")
    end

    it "creates an admin user when admin flag is true" do
      variables = {
        name: "Admin User",
        email: "adminuser@example.com",
        password: "password123",
        passwordConfirmation: "password123",
        admin: true
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createUser"]["user"]["admin"]).to eq(true)

      user = User.find_by(email: "adminuser@example.com")
      expect(user.admin?).to eq(true)
    end

    it "uses password as password_confirmation when not provided" do
      variables = {
        name: "New User",
        email: "newuser@example.com",
        password: "password123"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createUser"]["user"]).not_to be_nil

      user = User.find_by(email: "newuser@example.com")
      expect(user).not_to be_nil
      expect(user.valid_password?("password123")).to be true
    end

    it "raises error for non-admin users" do
      variables = {
        name: "New User",
        email: "newuser@example.com",
        password: "password123"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: regular_context)

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end

    it "raises error when not authenticated" do
      variables = {
        name: "New User",
        email: "newuser@example.com",
        password: "password123"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: { current_user: nil })

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end

    it "returns errors when user is invalid" do
      variables = {
        name: nil,
        email: "invalid-email",
        password: "short"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createUser"]["user"]).to be_nil
      expect(result["data"]["createUser"]["errors"]).not_to be_empty
    end

    it "returns errors when email is already taken" do
      User.create!(name: "Existing", email: "existing@example.com", password: "password123", password_confirmation: "password123")

      variables = {
        name: "New User",
        email: "existing@example.com",
        password: "password123",
        passwordConfirmation: "password123"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createUser"]["user"]).to be_nil
      expect(result["data"]["createUser"]["errors"]).not_to be_empty
      expect(result["data"]["createUser"]["errors"].join(" ")).to include("has already been taken")
    end

    it "normalizes email to lowercase" do
      variables = {
        name: "New User",
        email: "NEWUSER@EXAMPLE.COM",
        password: "password123",
        passwordConfirmation: "password123"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: admin_context)

      expect(result["errors"]).to be_nil
      user = User.find_by(email: "newuser@example.com")
      expect(user).not_to be_nil
    end
  end
end
