# frozen_string_literal: true

module Mutations
  class CreateTask < BaseMutation
    description "Create a new task within a project"

    argument :project_id, ID, required: true
    argument :title, String, required: true
    argument :description, String, required: false
    argument :status, Types::TaskStatusEnum, required: false
    argument :due_at, GraphQL::Types::ISO8601DateTime, required: false

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(project_id:, title:, description: nil, status: nil, due_at: nil)
      result = Core::Services::TaskService.create(
        project_id: project_id,
        title: title,
        description: description,
        status: status,
        due_at: due_at
      )

      {
        task: result[:task],
        errors: result[:errors]
      }
    end
  end
end
