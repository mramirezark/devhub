# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    description "Create a new project to group related tasks"

    argument :name, String, required: true
    argument :description, String, required: false

    field :project, Types::ProjectType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, description: nil)
      result = Core::Services::ProjectService.create(name: name, description: description)

      {
        project: result[:project],
        errors: result[:errors]
      }
    end
  end
end
