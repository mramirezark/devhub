module Mutations
  class DeleteUser < BaseMutation
    description "Delete a user account"

    argument :id, ::GraphQL::Types::ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      user = locate_record(User, id)
      return { success: false, errors: [ "User not found" ] } unless user

      if user.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: user.errors.full_messages }
      end
    end
  end
end
