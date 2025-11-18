# frozen_string_literal: true

require "test_helper"

module Core
  module Services
    class ActivityServiceTest < ActiveSupport::TestCase
      setup do
        @project = create(:project)
        @task = create(:task, project: @project)
      end

      test "list returns all activities ordered by recent" do
        activity1 = Activity.create!(record: @task, action: "Action 1", created_at: 2.days.ago)
        activity2 = Activity.create!(record: @task, action: "Action 2", created_at: 1.day.ago)
        activity3 = Activity.create!(record: @task, action: "Action 3", created_at: Time.current)

        activities = ActivityService.list

        assert_equal [ activity3, activity2, activity1 ].map(&:id), activities.map(&:id)
      end

      test "list filters by task_id" do
        task2 = create(:task, project: @project)
        activity1 = Activity.create!(record: @task, action: "Task 1 Activity")
        activity2 = Activity.create!(record: task2, action: "Task 2 Activity")

        activities = ActivityService.list(task_id: @task.id)

        assert_includes activities.map(&:id), activity1.id
        assert_not_includes activities.map(&:id), activity2.id
      end

      test "list returns empty when task_id is invalid" do
        Activity.create!(record: @task, action: "Action")

        activities = ActivityService.list(task_id: 99999)

        assert_empty activities
      end

      test "list returns all activities when task_id is nil" do
        task2 = create(:task, project: @project)
        activity1 = Activity.create!(record: @task, action: "Task 1 Activity")
        activity2 = Activity.create!(record: task2, action: "Task 2 Activity")

        activities = ActivityService.list

        assert_includes activities.map(&:id), activity1.id
        assert_includes activities.map(&:id), activity2.id
      end
    end
  end
end
