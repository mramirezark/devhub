# frozen_string_literal: true

module Queries
  module TaskQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery

    included do
      field :tasks, [ Types::TaskType ], null: false,
        description: "List tasks, optionally filtered by project or status" do
          argument :project_id, ::GraphQL::Types::ID, required: false
          argument :status, Types::TaskStatusEnum, required: false
        end

      field :task, Types::TaskType, null: true,
        description: "Lookup a task by ID" do
          argument :id, ::GraphQL::Types::ID, required: true
        end
    end

    def tasks(project_id: nil, status: nil)
      scope = Task.includes(:project, :activities)

      if project_id.present?
        normalized_project_id = extract_record_id(Project, project_id)
        scope = scope.where(project_id: normalized_project_id) if normalized_project_id
      end

      scope = scope.public_send(status) if status.present?
      scope
    end

    def task(id:)
      locate_record(Task, id)
    end
  end
end
