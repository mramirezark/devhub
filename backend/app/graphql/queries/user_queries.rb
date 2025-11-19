# frozen_string_literal: true

module Queries
  module UserQueries
    extend ActiveSupport::Concern
    include Queries::BaseQuery
    include GraphqlConcerns::AdminAuthorization

    included do
      field :users, Types::UserType.connection_type, null: false,
        description: "List all users in the system (admin only)"

      field :user, Types::UserType, null: true,
        description: "Lookup a user by ID (admin only)" do
          argument :id, ::GraphQL::Types::ID, required: true
        end

      field :admin_users, Types::UserType.connection_type, null: false,
        description: "List all users (admin only)"

      field :admin_stats, Types::AdminStatsType, null: false,
        description: "Get admin dashboard statistics (admin only)"

      field :assignable_users, Types::UserType.connection_type, null: false,
        description: "List all users available for task assignment (authenticated users)"
    end

    def users(**pagination_args)
      require_admin!
      Admin::Services::UserService.list
    end

    def user(id:)
      require_admin!
      Admin::Services::UserService.find(id)
    end

    def admin_users(**pagination_args)
      require_admin!
      Admin::Services::UserService.list
    end

    def admin_stats
      require_admin!
      Admin::Services::AdminStatsService.stats
    end

    def assignable_users(**pagination_args)
      # All authenticated users can see the list of users for assignment
      require_authenticated_user!
      User.all.order(:name)
    end
  end
end
