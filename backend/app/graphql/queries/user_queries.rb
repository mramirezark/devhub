# frozen_string_literal: true

module Queries
  module UserQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery

    included do
      field :users, [ Types::UserType ], null: false,
        description: "List all users in the system"

      field :user, Types::UserType, null: true,
        description: "Lookup a user by ID" do
          argument :id, ::GraphQL::Types::ID, required: true
        end
    end

    def users
      User.all
    end

    def user(id:)
      locate_record(User, id)
    end
  end
end
