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
      Core::Services::TaskService.list(project_id: project_id, status: status)
    end

    def task(id:)
      Core::Services::TaskService.find(id)
    end
  end
end
