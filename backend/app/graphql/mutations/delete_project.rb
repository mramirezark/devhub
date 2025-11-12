module Mutations
  class DeleteProject < BaseMutation
    description "Delete a project and its associated tasks"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      project = locate_record(Project, id)
      return { success: false, errors: [ "Project not found" ] } unless project

      project.destroy!
      { success: true, errors: [] }
    rescue StandardError => error
      { success: false, errors: [ error.message ] }
    end
  end
end
