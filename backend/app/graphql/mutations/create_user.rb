# frozen_string_literal: true

module Mutations
  class CreateUser < BaseMutation
    include GraphqlConcerns::AdminAuthorization

    description "Create a new user (admin only)"

    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: false
    argument :admin, Boolean, required: false

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, email:, password:, password_confirmation: nil, admin: false)
      require_admin!

      result = Admin::Services::UserService.create(
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        admin: admin
      )

      {
        user: result[:user],
        errors: result[:errors]
      }
    end
  end
end
