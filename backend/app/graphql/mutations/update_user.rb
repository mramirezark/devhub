module Mutations
  class UpdateUser < BaseMutation
    description "Update a user's profile or admin status"

    argument :id, ::GraphQL::Types::ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false
    argument :admin, Boolean, required: false

    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      user = locate_record(User, id)
      return { user: nil, errors: [ "User not found" ] } unless user

      if attributes.empty?
        { user: user, errors: [] }
      elsif user.update(attributes)
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
