# frozen_string_literal: true

module Types
  class ActivityType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    field :record_type, String, null: false
    field :record_id, ID, null: false
    field :action, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :record, Types::TaskType, null: true

    def record
      return object.record if object.record_type == "Task"

      nil
    end
  end
end
