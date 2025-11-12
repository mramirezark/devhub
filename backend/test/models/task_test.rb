require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "status change enqueues ActivityLoggerJob" do
    project = Project.create!(name: "Minitest Project")
    task = project.tasks.create!(title: "Draft plan", status: :pending)

    assert_enqueued_with(job: ActivityLoggerJob, args: [task.id, "pending", "completed"]) do
      task.update!(status: :completed)
    end
  end
end

