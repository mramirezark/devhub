# frozen_string_literal: true

require "rails_helper"

RSpec.describe Queries::UserQueries, type: :graphql do
  let(:admin_user) { User.create!(name: "Admin", email: "admin@example.com", password: "password123", password_confirmation: "password123", admin: true) }
  let(:regular_user) { User.create!(name: "Regular User", email: "user@example.com", password: "password123", password_confirmation: "password123", admin: false) }
  let(:admin_context) { { current_user: admin_user, current_user_session: nil } }
  let(:regular_context) { { current_user: regular_user, current_user_session: nil } }

  describe "#users" do
    let(:query) do
      <<~GRAPHQL
        query {
          users {
            id
            name
            email
            admin
          }
        }
      GRAPHQL
    end

    it "returns all users for admin" do
      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      users = result["data"]["users"]
      expect(users.length).to eq(2)
      expect(users.map { |u| u["email"] }).to contain_exactly("admin@example.com", "user@example.com")
    end

    it "raises error for non-admin users" do
      result = BackendSchema.execute(query, context: regular_context)

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end

    it "raises error when not authenticated" do
      result = BackendSchema.execute(query, context: { current_user: nil })

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end
  end

  describe "#user" do
    it "returns a user by id for admin" do
      query = <<~GRAPHQL
        query {
          user(id: "#{regular_user.to_gid_param}") {
            id
            name
            email
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["user"]["id"]).to eq(regular_user.to_gid_param)
      expect(result["data"]["user"]["name"]).to eq("Regular User")
    end

    it "raises error for non-admin users" do
      query = <<~GRAPHQL
        query {
          user(id: "#{regular_user.to_gid_param}") {
            id
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: regular_context)

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end

    it "returns null when user not found" do
      query = <<~GRAPHQL
        query {
          user(id: "gid://backend/User/99999") {
            id
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["user"]).to be_nil
    end
  end

  describe "#admin_users" do
    it "returns paginated users for admin" do
      # Create additional users
      User.create!(name: "User 1", email: "user1@example.com", password: "password123", password_confirmation: "password123")
      User.create!(name: "User 2", email: "user2@example.com", password: "password123", password_confirmation: "password123")

      query = <<~GRAPHQL
        query {
          adminUsers(limit: 2, offset: 0) {
            id
            name
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      users = result["data"]["adminUsers"]
      expect(users.length).to eq(2)
    end

    it "raises error for non-admin users" do
      query = <<~GRAPHQL
        query {
          adminUsers {
            id
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: regular_context)

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end
  end

  describe "#admin_stats" do
    it "returns admin statistics for admin" do
      project = Project.create!(name: "Test Project")
      project.tasks.create!(title: "Task 1", status: :pending)
      project.tasks.create!(title: "Task 2", status: :completed)

      query = <<~GRAPHQL
        query {
          adminStats {
            totalUsers
            totalProjects
            totalTasks
            completedTasks
            pendingTasks
            inProgressTasks
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      stats = result["data"]["adminStats"]
      expect(stats["totalUsers"]).to eq(2)
      expect(stats["totalProjects"]).to eq(1)
      expect(stats["totalTasks"]).to eq(2)
      expect(stats["completedTasks"]).to eq(1)
      expect(stats["pendingTasks"]).to eq(1)
      expect(stats["inProgressTasks"]).to eq(0)
    end

    it "raises error for non-admin users" do
      query = <<~GRAPHQL
        query {
          adminStats {
            totalUsers
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: regular_context)

      expect(result["errors"]).not_to be_nil
      expect(result["errors"].first["message"]).to eq("Admin access required")
    end
  end

  describe "#assignable_users" do
    it "returns all users for authenticated users" do
      query = <<~GRAPHQL
        query {
          assignableUsers {
            id
            name
            email
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: regular_context)

      expect(result["errors"]).to be_nil
      users = result["data"]["assignableUsers"]
      expect(users.length).to eq(2)
      expect(users.map { |u| u["email"] }).to contain_exactly("admin@example.com", "user@example.com")
    end

    it "works for admin users" do
      query = <<~GRAPHQL
        query {
          assignableUsers {
            id
            name
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: admin_context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["assignableUsers"].length).to eq(2)
    end

    it "works without authentication" do
      query = <<~GRAPHQL
        query {
          assignableUsers {
            id
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: { current_user: nil })

      expect(result["errors"]).to be_nil
      expect(result["data"]["assignableUsers"]).to be_an(Array)
    end
  end
end
