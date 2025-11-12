# frozen_string_literal: true

module Types
  class TaskType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    field :title, String, null: false
    field :description, String, null: true
    field :status, Types::TaskStatusEnum, null: false
    field :due_at, GraphQL::Types::ISO8601DateTime, null: true
    field :project, Types::ProjectType, null: false
    field :assignee, Types::UserType, null: true
    field :activities, [ Types::ActivityType ], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def assignee
      return unless object.assignee_type == "User"

      object.assignee
    end

    def activities
      object.activities
    end
  end
end
