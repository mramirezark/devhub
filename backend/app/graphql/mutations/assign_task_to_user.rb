# frozen_string_literal: true

module Mutations
  class AssignTaskToUser < BaseMutation
    description "Assign a task to a specific user"

    argument :task_id, ID, required: true
    argument :user_id, ID, required: true

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(task_id:, user_id:)
      task = locate_record(Task, task_id)
      user = locate_record(User, user_id)

      return { task: nil, errors: [ "Task not found" ] } if task.nil?
      return { task: nil, errors: [ "User not found" ] } if user.nil?

      if task.update(assignee: user)
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
