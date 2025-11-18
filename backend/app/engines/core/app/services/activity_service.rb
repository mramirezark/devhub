# frozen_string_literal: true

module Core
  module Services
    class ActivityService
      extend Core::Services::Concerns::RecordLocator
      def self.list(task_id: nil)
        scope = Activity.includes(:record)

        if task_id.present?
          normalized_task_id = extract_record_id(Task, task_id)
          if normalized_task_id
            scope = scope.where(record_type: "Task", record_id: normalized_task_id)
          else
            scope = scope.none
          end
        end

        scope.recent
      end
    end
  end
end
