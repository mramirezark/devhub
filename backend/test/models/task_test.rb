require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    task = build(:task)
    assert task.valid?
  end

  test "should require title" do
    task = build(:task, title: nil)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should require status" do
    task = build(:task, status: nil)
    assert_not task.valid?
    assert_includes task.errors[:status], "can't be blank"
  end

  test "should belong to project" do
    project = create(:project)
    task = create(:task, project: project)
    assert_equal project, task.project
  end

  test "should have valid status enum values" do
    assert Task.statuses.key?("pending")
    assert Task.statuses.key?("in_progress")
    assert Task.statuses.key?("completed")
  end

  test "should default to pending status" do
    task = create(:task)
    assert_equal "pending", task.status
  end

  test "should allow optional assignee" do
    user = create(:user)
    task = create(:task, assignee: user)
    assert_equal user, task.assignee
  end

  test "should validate assignee_type is User" do
    task = build(:task, assignee_type: "InvalidType", assignee_id: 1)
    assert_not task.valid?
    assert_includes task.errors[:assignee_type], "must be User"
  end

  test "should allow nil assignee" do
    task = create(:task, assignee: nil)
    assert_nil task.assignee
    assert task.valid?
  end

  test "should have many activities" do
    task = create(:task)
    activity1 = create(:activity, record: task)
    activity2 = create(:activity, record: task)

    assert_equal 2, task.activities.count
    assert_includes task.activities, activity1
    assert_includes task.activities, activity2
  end

  test "should destroy associated activities when task is destroyed" do
    task = create(:task)
    activity = create(:activity, record: task)

    task.destroy

    assert_raises(ActiveRecord::RecordNotFound) { activity.reload }
  end

  test "completed scope should return only completed tasks" do
    pending_task = create(:task, :pending)
    in_progress_task = create(:task, :in_progress)
    completed_task1 = create(:task, :completed)
    completed_task2 = create(:task, :completed)

    completed_tasks = Task.completed

    assert_includes completed_tasks, completed_task1
    assert_includes completed_tasks, completed_task2
    assert_not_includes completed_tasks, pending_task
    assert_not_includes completed_tasks, in_progress_task
  end

  test "recent scope should order by created_at descending" do
    task1 = create(:task)
    sleep(0.01) # Ensure different timestamps
    task2 = create(:task)
    sleep(0.01)
    task3 = create(:task)

    recent_tasks = Task.recent.limit(3)

    assert_equal task3, recent_tasks.first
    assert_equal task2, recent_tasks.second
    assert_equal task1, recent_tasks.third
  end

  test "assigned_to scope should return tasks assigned to user" do
    user1 = create(:user)
    user2 = create(:user)

    task1 = create(:task, assignee: user1)
    task2 = create(:task, assignee: user1)
    task3 = create(:task, assignee: user2)
    unassigned_task = create(:task, assignee: nil)

    user1_tasks = Task.assigned_to(user1)

    assert_includes user1_tasks, task1
    assert_includes user1_tasks, task2
    assert_not_includes user1_tasks, task3
    assert_not_includes user1_tasks, unassigned_task
  end

  test "status change enqueues ActivityLoggerJob" do
    task = create(:task, :pending)

    assert_enqueued_with(job: ActivityLoggerJob, args: [ task.id, "pending", "completed" ]) do
      task.update!(status: :completed)
    end
  end

  test "should not enqueue job if status does not change" do
    task = create(:task)

    assert_no_enqueued_jobs(only: ActivityLoggerJob) do
      task.update!(title: "Updated Title")
    end
  end

  test "should not enqueue job on create" do
    assert_no_enqueued_jobs(only: ActivityLoggerJob) do
      create(:task)
    end
  end

  test "should allow due_at date" do
    due_date = 1.week.from_now
    task = create(:task, :with_due_date)
    assert_not_nil task.due_at
  end

  test "should allow description" do
    task = create(:task, :with_description)
    assert_equal "A detailed task description", task.description
  end

  test "should create task with assigned trait" do
    task = create(:task, :assigned)
    assert_not_nil task.assignee
    assert_instance_of User, task.assignee
  end

  test "should create task with activities trait" do
    task = create(:task, :with_activities)
    assert_equal 3, task.activities.count
  end
end
