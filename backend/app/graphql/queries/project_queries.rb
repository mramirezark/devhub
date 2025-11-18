# frozen_string_literal: true

module Queries
  module ProjectQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery

    included do
      field :projects, [ Types::ProjectType ], null: false,
        description: "List all projects"

      field :project, Types::ProjectType, null: true,
        description: "Lookup a project by ID" do
          argument :id, ::GraphQL::Types::ID, required: true
        end
    end

    def projects
      Core::Services::ProjectService.list
    end

    def project(id:)
      Core::Services::ProjectService.find(id)
    end
  end
end
