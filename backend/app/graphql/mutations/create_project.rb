# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    description "Create a new project to group related tasks"

    argument :name, String, required: true
    argument :description, String, required: false

    field :project, Types::ProjectType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, description: nil)
      project = Project.new(name:, description:)

      if project.save
        { project: project, errors: [] }
      else
        { project: nil, errors: project.errors.full_messages }
      end
    end
  end
end
