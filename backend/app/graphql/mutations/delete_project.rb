# frozen_string_literal: true

module Mutations
  class DeleteProject < BaseMutation
    description "Delete a project and its associated tasks"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      Core::Services::ProjectService.delete(id: id)
    end
  end
end
