# frozen_string_literal: true

module Mutations
  class AssignTaskToUser < BaseMutation
    description "Assign a task to a specific user"

    argument :task_id, ID, required: true
    argument :user_id, ID, required: true

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(task_id:, user_id:)
      result = Core::Services::TaskService.assign_to_user(task_id: task_id, user_id: user_id)

      {
        task: result[:task],
        errors: result[:errors]
      }
    end
  end
end
