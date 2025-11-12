# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    field :name, String, null: false
    field :description, String, null: true
    field :tasks, [ Types::TaskType ], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def tasks
      object.tasks.includes(:activities)
    end
  end
end
