# frozen_string_literal: true

module Mutations
  class DeleteUser < BaseMutation
    include GraphqlConcerns::AdminAuthorization

    description "Delete a user account (admin only)"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      require_admin!

      Admin::Services::UserService.delete(
        id: id,
        current_user_id: context[:current_user]&.id
      )
    end
  end
end
