# frozen_string_literal: true

module Mutations
  class CreateUser < BaseMutation
    description "Create a new user who can be assigned to tasks"

    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: false
    argument :admin, Boolean, required: false

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, email:, password:, password_confirmation: nil, admin: false)
      user = User.new(
        name:,
        email:,
        password:,
        password_confirmation: password_confirmation.presence || password,
        admin: admin
      )

      if user.save
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
