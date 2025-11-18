# frozen_string_literal: true

module UserSerializer
  extend ActiveSupport::Concern

  def user_payload(user, include_admin: false)
    payload = {
      id: user.id,
      name: user.name,
      email: user.email
    }
    payload[:admin] = user.admin? if include_admin
    payload
  end
end
