# frozen_string_literal: true

class UserRegistrationService
  Result = Struct.new(:user, :user_session, :errors, keyword_init: true)

  attr_reader :attributes

  def self.call(attributes:)
    new(attributes: attributes).call
  end

  def initialize(attributes:)
    @attributes = attributes.is_a?(ActionController::Parameters) ? attributes.to_h.symbolize_keys : attributes.symbolize_keys
  end

  def call
    User.transaction do
      user = User.new(permitted_attributes)

      if user.save
        user_session = UserSession.create(user)
        Result.new(user: user, user_session: user_session, errors: [])
      else
        Result.new(user: nil, user_session: nil, errors: user.errors.full_messages)
      end
    end
  end

  private

  def permitted_attributes
    attributes.slice(:name, :email, :password, :password_confirmation)
  end
end
