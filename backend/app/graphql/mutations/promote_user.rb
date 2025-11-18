# frozen_string_literal: true

module Mutations
  class PromoteUser < BaseMutation
    include GraphqlConcerns::AdminAuthorization

    description "Promote a user to admin (admin only)"

    argument :user_id, ID, required: true, description: "ID of the user to promote"

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(user_id:)
      require_admin!

      result = Admin::Services::UserService.promote(id: user_id)
      {
        user: result[:user],
        errors: result[:errors]
      }
    end
  end
end
