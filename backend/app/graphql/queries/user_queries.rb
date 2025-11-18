# frozen_string_literal: true

module Queries
  module UserQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery
    include GraphqlConcerns::AdminAuthorization

    included do
      field :users, [ Types::UserType ], null: false,
        description: "List all users in the system (admin only)"

      field :user, Types::UserType, null: true,
        description: "Lookup a user by ID (admin only)" do
          argument :id, ::GraphQL::Types::ID, required: true
        end

      field :admin_users, [ Types::UserType ], null: false,
        description: "List all users (admin only)" do
          argument :limit, Integer, required: false, default_value: 50
          argument :offset, Integer, required: false, default_value: 0
        end

      field :admin_stats, Types::AdminStatsType, null: false,
        description: "Get admin dashboard statistics (admin only)"
    end

    def users
      require_admin!
      Admin::Services::UserService.list
    end

    def user(id:)
      require_admin!
      Admin::Services::UserService.find(id)
    end

    def admin_users(limit: 50, offset: 0)
      require_admin!
      Admin::Services::UserService.list.limit(limit).offset(offset)
    end

    def admin_stats
      require_admin!
      Admin::Services::AdminStatsService.stats
    end
  end
end
