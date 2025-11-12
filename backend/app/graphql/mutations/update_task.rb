# frozen_string_literal: true

module Mutations
  class UpdateTask < BaseMutation
    description "Update an existing task"

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :status, Types::TaskStatusEnum, required: false
    argument :due_at, GraphQL::Types::ISO8601DateTime, required: false

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, title: nil, description: nil, status: nil, due_at: nil)
      task = locate_record(Task, id)
      return { task: nil, errors: [ "Task not found" ] } if task.nil?

    result = TaskStatusUpdater.call(
      task: task,
      attributes: {
        title: title,
        description: description,
        status: status,
        due_at: due_at
      }
    )

    {
      task: result.task,
      errors: result.errors
    }
    end
  end
end
