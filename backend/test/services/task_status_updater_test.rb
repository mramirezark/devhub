require "test_helper"

class TaskStatusUpdaterTest < ActiveSupport::TestCase
  test "updates the task and logs activity" do
    project = Project.create!(name: "Service Project")
    task = project.tasks.create!(title: "Ship feature", status: :pending)

    perform_enqueued_jobs do
      result = TaskStatusUpdater.call(task:, attributes: { status: "completed" })

      assert result.errors.empty?, "Expected result to be successful"
      assert_equal "completed", task.reload.status
    end

    activity = task.activities.last
    assert_not_nil activity
    assert_includes activity.action, "Task status changed"
  end
end

