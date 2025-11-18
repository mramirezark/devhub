# frozen_string_literal: true

module Mutations
  class UpdateProject < BaseMutation
    description "Update an existing project"

    argument :id, ::GraphQL::Types::ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false

    field :project, Types::ProjectType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, name: nil, description: nil)
      result = Core::Services::ProjectService.update(id: id, name: name, description: description)

      {
        project: result[:project],
        errors: result[:errors]
      }
    end
  end
end
