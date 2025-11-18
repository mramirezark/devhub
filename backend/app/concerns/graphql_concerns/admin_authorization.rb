# frozen_string_literal: true

module GraphqlConcerns
  module AdminAuthorization
    private

    def require_admin!
      return if context[:current_user]&.admin?

      raise GraphQL::ExecutionError, "Admin access required"
    end
  end
end
