# frozen_string_literal: true

module GraphqlConcerns
  module AdminAuthorization
    private

    def require_authenticated_user!
      return if context[:current_user].present?

      raise GraphQL::ExecutionError, "Authentication required"
    end

    def require_admin!
      require_authenticated_user!
      return if context[:current_user]&.admin?

      raise GraphQL::ExecutionError, "Admin access required"
    end
  end
end
