# frozen_string_literal: true

module GraphqlConcerns
  module CurrentUserContext
    extend ActiveSupport::Concern

    private

    def current_user
      context[:current_user]
    end
  end
end
