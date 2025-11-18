# frozen_string_literal: true

module Mutations
  class UpdateUser < BaseMutation
    include GraphqlConcerns::AdminAuthorization

    description "Update a user's profile or admin status (admin only)"

    argument :id, ::GraphQL::Types::ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false
    argument :admin, Boolean, required: false

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, name: nil, email: nil, admin: nil)
      require_admin!

      result = Admin::Services::UserService.update(
        id: id,
        name: name,
        email: email,
        admin: admin
      )

      {
        user: result[:user],
        errors: result[:errors]
      }
    end
  end
end
