# frozen_string_literal: true

module Queries
  module ActivityQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery

    included do
      field :activities, [ Types::ActivityType ], null: false,
        description: "List task activities, optionally filtered by task" do
          argument :task_id, ::GraphQL::Types::ID, required: false
        end
    end

    def activities(task_id: nil)
      scope = Activity.includes(:record)

      if task_id.present?
        normalized_task_id = extract_record_id(Task, task_id)
        if normalized_task_id
          scope = scope.where(record_type: "Task", record_id: normalized_task_id)
        else
          scope = scope.none
        end
      end

      scope.order(created_at: :desc)
    end
  end
end
