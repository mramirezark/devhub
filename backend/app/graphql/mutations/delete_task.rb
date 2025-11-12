module Mutations
  class DeleteTask < BaseMutation
    description "Delete a task"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      task = locate_record(Task, id)
      return { success: false, errors: [ "Task not found" ] } unless task

      task.destroy!
      { success: true, errors: [] }
    rescue StandardError => error
      { success: false, errors: [ error.message ] }
    end
  end
end
