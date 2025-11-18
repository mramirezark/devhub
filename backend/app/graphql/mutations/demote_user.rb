# frozen_string_literal: true

module Mutations
  class DemoteUser < BaseMutation
    include GraphqlConcerns::AdminAuthorization

    description "Demote an admin user (admin only)"

    argument :user_id, ID, required: true, description: "ID of the user to demote"

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(user_id:)
      require_admin!

      result = Admin::Services::UserService.demote(
        id: user_id,
        current_user_id: context[:current_user]&.id
      )
      {
        user: result[:user],
        errors: result[:errors]
      }
    end
  end
end
