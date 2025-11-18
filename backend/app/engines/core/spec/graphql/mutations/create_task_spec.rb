# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreateTask, type: :graphql do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password123", password_confirmation: "password123") }
  let(:project) { Project.create!(name: "Test Project") }
  let(:context) { { current_user: user, current_user_session: nil } }

  describe "#resolve" do
    let(:mutation) do
      <<~GRAPHQL
        mutation CreateTask($projectId: ID!, $title: String!, $description: String, $status: TaskStatusEnum) {
          createTask(
            projectId: $projectId
            title: $title
            description: $description
            status: $status
          ) {
            task {
              id
              title
              description
              status
            }
            errors
          }
        }
      GRAPHQL
    end

    it "creates a task successfully" do
      variables = {
        projectId: project.id.to_s,
        title: "New Task",
        description: "Task description",
        status: "PENDING"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["errors"]).to eq([])
      expect(result["data"]["createTask"]["task"]).not_to be_nil
      expect(result["data"]["createTask"]["task"]["title"]).to eq("New Task")
      expect(result["data"]["createTask"]["task"]["description"]).to eq("Task description")
      expect(result["data"]["createTask"]["task"]["status"]).to eq("PENDING")

      task = Task.find_by(title: "New Task")
      expect(task).not_to be_nil
      expect(task.project).to eq(project)
    end

    it "creates a task with default status when status not provided" do
      variables = {
        projectId: project.id.to_s,
        title: "New Task"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]["status"]).to eq("PENDING")
    end

    it "creates a task without description" do
      variables = {
        projectId: project.id.to_s,
        title: "New Task",
        status: "IN_PROGRESS"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]["description"]).to be_nil
    end

    it "returns errors when project not found" do
      variables = {
        projectId: "99999",
        title: "New Task"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]).to be_nil
      expect(result["data"]["createTask"]["errors"]).to include("Project not found")
    end

    it "returns errors when task is invalid" do
      variables = {
        projectId: project.id.to_s,
        title: nil
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]).to be_nil
      expect(result["data"]["createTask"]["errors"]).not_to be_empty
    end

    it "accepts global id for project" do
      variables = {
        projectId: project.to_gid_param,
        title: "New Task"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: context)

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]).not_to be_nil
    end

    it "works without authentication" do
      variables = {
        projectId: project.id.to_s,
        title: "New Task"
      }

      result = BackendSchema.execute(mutation, variables: variables, context: { current_user: nil })

      expect(result["errors"]).to be_nil
      expect(result["data"]["createTask"]["task"]).not_to be_nil
    end
  end
end
