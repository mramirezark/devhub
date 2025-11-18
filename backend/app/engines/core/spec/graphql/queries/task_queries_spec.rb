# frozen_string_literal: true

require "rails_helper"

RSpec.describe Queries::TaskQueries, type: :graphql do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password123", password_confirmation: "password123") }
  let(:project) { Project.create!(name: "Test Project") }
  let(:context) { { current_user: user, current_user_session: nil } }
  let(:query_type) { Class.new(GraphQL::Schema::Object) { include Queries::TaskQueries } }
  let(:schema) { GraphQL::Schema.define(query: query_type) }

  describe "#tasks" do
    let(:query) do
      <<~GRAPHQL
        query {
          tasks {
            id
            title
            status
            project {
              id
              name
            }
          }
        }
      GRAPHQL
    end

    it "returns all tasks ordered by recent" do
      task1 = project.tasks.create!(title: "Task 1", status: :pending, created_at: 2.days.ago)
      _task2 = project.tasks.create!(title: "Task 2", status: :in_progress, created_at: 1.day.ago)
      task3 = project.tasks.create!(title: "Task 3", status: :completed, created_at: Time.current)

      result = BackendSchema.execute(query, context: context)

      expect(result["errors"]).to be_nil
      tasks = result["data"]["tasks"]
      expect(tasks.length).to eq(3)
      expect(tasks.first["id"]).to eq(task3.to_gid_param)
      expect(tasks.last["id"]).to eq(task1.to_gid_param)
    end

    it "filters tasks by project_id" do
      project2 = Project.create!(name: "Project 2")
      task1 = project.tasks.create!(title: "Task 1", status: :pending)
      _task2 = project2.tasks.create!(title: "Task 2", status: :pending)

      query_with_filter = <<~GRAPHQL
        query {
          tasks(projectId: "#{project.id}") {
            id
            title
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query_with_filter, context: context)

      expect(result["errors"]).to be_nil
      tasks = result["data"]["tasks"]
      expect(tasks.length).to eq(1)
      expect(tasks.first["id"]).to eq(task1.to_gid_param)
    end

    it "filters tasks by status completed" do
      completed_task = project.tasks.create!(title: "Completed Task", status: :completed)
      _pending_task = project.tasks.create!(title: "Pending Task", status: :pending)

      query_with_status = <<~GRAPHQL
        query {
          tasks(status: COMPLETED) {
            id
            title
            status
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query_with_status, context: context)

      expect(result["errors"]).to be_nil
      tasks = result["data"]["tasks"]
      expect(tasks.length).to eq(1)
      expect(tasks.first["id"]).to eq(completed_task.to_gid_param)
      expect(tasks.first["status"]).to eq("COMPLETED")
    end

    it "filters tasks by status pending" do
      _completed_task = project.tasks.create!(title: "Completed Task", status: :completed)
      pending_task = project.tasks.create!(title: "Pending Task", status: :pending)

      query_with_status = <<~GRAPHQL
        query {
          tasks(status: PENDING) {
            id
            title
            status
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query_with_status, context: context)

      expect(result["errors"]).to be_nil
      tasks = result["data"]["tasks"]
      expect(tasks.length).to eq(1)
      expect(tasks.first["id"]).to eq(pending_task.to_gid_param)
      expect(tasks.first["status"]).to eq("PENDING")
    end

    it "returns empty array when no tasks exist" do
      result = BackendSchema.execute(query, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["tasks"]).to eq([])
    end

    it "works without authentication" do
      _task = project.tasks.create!(title: "Public Task", status: :pending)

      result = BackendSchema.execute(query, context: { current_user: nil })

      expect(result["errors"]).to be_nil
      expect(result["data"]["tasks"].length).to eq(1)
    end
  end

  describe "#task" do
    let(:task) { project.tasks.create!(title: "Test Task", status: :pending) }

    it "returns a task by id" do
      query = <<~GRAPHQL
        query {
          task(id: "#{task.to_gid_param}") {
            id
            title
            status
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["task"]["id"]).to eq(task.to_gid_param)
      expect(result["data"]["task"]["title"]).to eq("Test Task")
      expect(result["data"]["task"]["status"]).to eq("PENDING")
    end

    it "returns null when task not found" do
      query = <<~GRAPHQL
        query {
          task(id: "gid://backend/Task/99999") {
            id
            title
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["task"]).to be_nil
    end

    it "accepts numeric id" do
      query = <<~GRAPHQL
        query {
          task(id: "#{task.id}") {
            id
            title
          }
        }
      GRAPHQL

      result = BackendSchema.execute(query, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["task"]["id"]).to eq(task.to_gid_param)
    end
  end
end
