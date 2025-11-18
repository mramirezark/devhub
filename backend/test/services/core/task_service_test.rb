# frozen_string_literal: true

require "test_helper"

module Core
  module Services
    class TaskServiceTest < ActiveSupport::TestCase
      setup do
        @project = create(:project, name: "Test Project")
        @user = create(:user)
      end

      test "list returns all tasks ordered by recent" do
        task1 = create(:task, project: @project, created_at: 2.days.ago)
        task2 = create(:task, project: @project, created_at: 1.day.ago)
        task3 = create(:task, project: @project, created_at: Time.current)

        tasks = TaskService.list

        assert_equal [ task3, task2, task1 ].map(&:id), tasks.map(&:id)
      end

      test "list filters by project_id" do
        project2 = create(:project)
        task1 = create(:task, project: @project)
        task2 = create(:task, project: project2)

        tasks = TaskService.list(project_id: @project.id)

        assert_includes tasks.map(&:id), task1.id
        assert_not_includes tasks.map(&:id), task2.id
      end

      test "list filters by status completed" do
        completed_task = create(:task, project: @project, status: :completed)
        pending_task = create(:task, project: @project, status: :pending)

        tasks = TaskService.list(status: "completed")

        assert_includes tasks.map(&:id), completed_task.id
        assert_not_includes tasks.map(&:id), pending_task.id
      end

      test "list filters by status pending" do
        completed_task = create(:task, project: @project, status: :completed)
        pending_task = create(:task, project: @project, status: :pending)

        tasks = TaskService.list(status: "pending")

        assert_includes tasks.map(&:id), pending_task.id
        assert_not_includes tasks.map(&:id), completed_task.id
      end

      test "find returns task by id" do
        task = create(:task, project: @project)

        found_task = TaskService.find(task.id)

        assert_equal task, found_task
      end

      test "find returns nil for non-existent task" do
        found_task = TaskService.find(99999)

        assert_nil found_task
      end

      test "create creates a new task" do
        result = TaskService.create(
          project_id: @project.id,
          title: "New Task",
          description: "Task description",
          status: "pending"
        )

        assert result[:success]
        assert_not_nil result[:task]
        assert_equal "New Task", result[:task].title
        assert_equal "Task description", result[:task].description
        assert_equal "pending", result[:task].status
        assert_empty result[:errors]
      end

      test "create uses default status pending when not provided" do
        result = TaskService.create(
          project_id: @project.id,
          title: "New Task"
        )

        assert result[:success]
        assert_equal "pending", result[:task].status
      end

      test "create returns error when project not found" do
        result = TaskService.create(
          project_id: 99999,
          title: "New Task"
        )

        assert_not result[:success]
        assert_nil result[:task]
        assert_includes result[:errors], "Project not found"
      end

      test "create returns errors when task is invalid" do
        result = TaskService.create(
          project_id: @project.id,
          title: nil
        )

        assert_not result[:success]
        assert_nil result[:task]
        assert_not_empty result[:errors]
      end

      test "update updates task attributes" do
        task = create(:task, project: @project, title: "Old Title", status: :pending)

        result = TaskService.update(
          id: task.id,
          title: "New Title",
          status: "completed"
        )

        assert result[:success]
        assert_equal "New Title", task.reload.title
        assert_equal "completed", task.status
        assert_empty result[:errors]
      end

      test "update returns error when task not found" do
        result = TaskService.update(id: 99999, title: "New Title")

        assert_not result[:success]
        assert_includes result[:errors], "Task not found"
      end

      test "delete destroys task" do
        task = create(:task, project: @project)

        result = TaskService.delete(id: task.id)

        assert result[:success]
        assert_empty result[:errors]
        assert_raises(ActiveRecord::RecordNotFound) { task.reload }
      end

      test "delete returns error when task not found" do
        result = TaskService.delete(id: 99999)

        assert_not result[:success]
        assert_includes result[:errors], "Task not found"
      end

      test "assign_to_user assigns task to user" do
        task = create(:task, project: @project, assignee: nil)

        result = TaskService.assign_to_user(task_id: task.id, user_id: @user.id)

        assert result[:success]
        assert_equal @user, task.reload.assignee
        assert_empty result[:errors]
      end

      test "assign_to_user returns error when task not found" do
        result = TaskService.assign_to_user(task_id: 99999, user_id: @user.id)

        assert_not result[:success]
        assert_includes result[:errors], "Task not found"
      end

      test "assign_to_user returns error when user not found" do
        task = create(:task, project: @project)

        result = TaskService.assign_to_user(task_id: task.id, user_id: 99999)

        assert_not result[:success]
        assert_includes result[:errors], "User not found"
      end
    end
  end
end
