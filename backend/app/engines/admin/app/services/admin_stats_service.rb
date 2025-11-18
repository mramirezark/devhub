# frozen_string_literal: true

module Admin
  module Services
    class AdminStatsService
      def self.stats
        {
          total_users: User.count,
          total_projects: Project.count,
          total_tasks: Task.count,
          completed_tasks: Task.completed.count,
          pending_tasks: Task.pending.count,
          in_progress_tasks: Task.in_progress.count
        }
      end
    end
  end
end
