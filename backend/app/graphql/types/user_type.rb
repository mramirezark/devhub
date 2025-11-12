# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    field :name, String, null: false
    field :email, String, null: false
    field :admin, Boolean, null: false
    field :assigned_tasks, [ Types::TaskType ], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def assigned_tasks
      object.assigned_tasks.includes(:project, :activities)
    end
  end
end
