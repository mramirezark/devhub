module Mutations
  class UpdateProject < BaseMutation
    description "Update an existing project"

    argument :id, ::GraphQL::Types::ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false

    field :project, Types::ProjectType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, name: nil, description: nil)
      project = locate_record(Project, id)
      return { project: nil, errors: [ "Project not found" ] } unless project

      attributes = {
        name: name,
        description: description
      }.compact

      if attributes.empty?
        { project: project, errors: [] }
      elsif project.update(attributes)
        { project: project, errors: [] }
      else
        { project: nil, errors: project.errors.full_messages }
      end
    end
  end
end
