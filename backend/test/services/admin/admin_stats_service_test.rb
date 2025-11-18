# frozen_string_literal: true

require "test_helper"

module Admin
  module Services
    class AdminStatsServiceTest < ActiveSupport::TestCase
      test "stats returns correct counts" do
        # Create test data
        create(:user)
        create(:user)
        project1 = create(:project)
        project2 = create(:project)
        create(:task, project: project1, status: :pending)
        create(:task, project: project1, status: :in_progress)
        create(:task, project: project2, status: :completed)
        create(:task, project: project2, status: :completed)

        stats = AdminStatsService.stats

        assert_equal 2, stats[:total_users]
        assert_equal 2, stats[:total_projects]
        assert_equal 4, stats[:total_tasks]
        assert_equal 2, stats[:completed_tasks]
        assert_equal 1, stats[:pending_tasks]
        assert_equal 1, stats[:in_progress_tasks]
      end

      test "stats returns zero counts when no data exists" do
        stats = AdminStatsService.stats

        assert_equal 0, stats[:total_users]
        assert_equal 0, stats[:total_projects]
        assert_equal 0, stats[:total_tasks]
        assert_equal 0, stats[:completed_tasks]
        assert_equal 0, stats[:pending_tasks]
        assert_equal 0, stats[:in_progress_tasks]
      end

      test "stats includes all required keys" do
        stats = AdminStatsService.stats

        assert stats.key?(:total_users)
        assert stats.key?(:total_projects)
        assert stats.key?(:total_tasks)
        assert stats.key?(:completed_tasks)
        assert stats.key?(:pending_tasks)
        assert stats.key?(:in_progress_tasks)
      end
    end
  end
end
