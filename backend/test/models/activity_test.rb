require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    activity = build(:activity)
    assert activity.valid?
  end

  test "should require record_type" do
    activity = build(:activity)
    activity.record_type = nil
    assert_not activity.valid?
    assert_includes activity.errors[:record_type], "can't be blank"
  end

  test "should require record_id" do
    activity = build(:activity)
    activity.record_id = nil
    assert_not activity.valid?
    assert_includes activity.errors[:record_id], "can't be blank"
  end

  test "should require action" do
    activity = build(:activity, action: nil)
    assert_not activity.valid?
    assert_includes activity.errors[:action], "can't be blank"
  end

  test "should belong to record polymorphically" do
    task = create(:task)
    activity = create(:activity, record: task)
    assert_equal task, activity.record
    assert_equal "Task", activity.record_type
    assert_equal task.id, activity.record_id
  end

  test "should work with different record types" do
    # Test with Task
    task = create(:task)
    task_activity = create(:activity, :for_task, record: task)
    assert_equal "Task", task_activity.record_type
    assert_equal task.id, task_activity.record_id

    # Test with Project
    project = create(:project)
    project_activity = create(:activity, :for_project, record: project)
    assert_equal "Project", project_activity.record_type
    assert_equal project.id, project_activity.record_id
  end

  test "recent scope should order by created_at descending" do
    task = create(:task)
    activity1 = create(:activity, record: task)
    sleep(0.01) # Ensure different timestamps
    activity2 = create(:activity, record: task)
    sleep(0.01)
    activity3 = create(:activity, record: task)

    recent_activities = Activity.recent.limit(3)

    assert_equal activity3, recent_activities.first
    assert_equal activity2, recent_activities.second
    assert_equal activity1, recent_activities.third
  end

  test "should have created_at timestamp" do
    activity = create(:activity)
    assert_not_nil activity.created_at
  end

  test "should allow various action strings" do
    actions = [ "created", "updated", "deleted", "status_changed", "assigned" ]

    actions.each do |action|
      activity = create(:activity, action: action)
      assert activity.valid?
      assert_equal action, activity.action
    end
  end

  test "should be queryable by record" do
    task1 = create(:task)
    task2 = create(:task)

    activity1 = create(:activity, record: task1)
    activity2 = create(:activity, record: task1)
    activity3 = create(:activity, record: task2)

    task_activities = Activity.where(record: task1)

    assert_includes task_activities, activity1
    assert_includes task_activities, activity2
    assert_not_includes task_activities, activity3
  end

  test "should be queryable by record_type and record_id" do
    task = create(:task)
    activity = create(:activity, record: task)

    found_activity = Activity.find_by(
      record_type: "Task",
      record_id: task.id
    )

    assert_equal activity, found_activity
  end

  test "should create activity with created trait" do
    activity = create(:activity, :created)
    assert_equal "created", activity.action
  end

  test "should create activity with updated trait" do
    activity = create(:activity, :updated)
    assert_equal "updated", activity.action
  end

  test "should create activity with deleted trait" do
    activity = create(:activity, :deleted)
    assert_equal "deleted", activity.action
  end

  test "should create activity with status_changed trait" do
    activity = create(:activity, :status_changed)
    assert_equal "status_changed", activity.action
  end
end
