# frozen_string_literal: true

module Mutations
  class CreateTask < BaseMutation
    description "Create a new task within a project"

    argument :project_id, ID, required: true
    argument :title, String, required: true
    argument :description, String, required: false
    argument :status, Types::TaskStatusEnum, required: false
    argument :due_at, GraphQL::Types::ISO8601DateTime, required: false

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(project_id:, title:, description: nil, status: nil, due_at: nil)
      project = locate_record(Project, project_id)
      return { task: nil, errors: [ "Project not found" ] } if project.nil?

      task = project.tasks.new(
        title:,
        description:,
        status: status || "pending",
        due_at: due_at
      )

      if task.save
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
