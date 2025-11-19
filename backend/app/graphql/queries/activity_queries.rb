# frozen_string_literal: true

module Queries
  module ActivityQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery

    included do
      field :activities, Types::ActivityType.connection_type, null: false,
        description: "List task activities, optionally filtered by task" do
          argument :task_id, ::GraphQL::Types::ID, required: false
        end
    end

    def activities(task_id: nil, **pagination_args)
      Core::Services::ActivityService.list(task_id: task_id)
    end
  end
end
