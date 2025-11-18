# frozen_string_literal: true

module Mutations
  class DeleteTask < BaseMutation
    description "Delete a task"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      Core::Services::TaskService.delete(id: id)
    end
  end
end
