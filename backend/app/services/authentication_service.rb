# frozen_string_literal: true

class AuthenticationService
  Result = Struct.new(:user, :user_session, :errors, keyword_init: true)

  attr_reader :email, :password, :remember_me

  def self.login(email:, password:, remember_me: false)
    new(email: email, password: password, remember_me: remember_me).login
  end

  def self.logout(user_session:)
    new.logout(user_session: user_session)
  end

  def initialize(email: nil, password: nil, remember_me: false)
    @email = email
    @password = password
    @remember_me = remember_me
  end

  def login
    user_session = UserSession.new(
      email: email,
      password: password,
      remember_me: remember_me
    )

    if user_session.save
      Result.new(user: user_session.user, user_session: user_session, errors: [])
    else
      Result.new(user: nil, user_session: nil, errors: user_session.errors.full_messages)
    end
  end

  def logout(user_session:)
    if user_session
      user_session.destroy
      Result.new(user: nil, user_session: nil, errors: [])
    else
      Result.new(user: nil, user_session: nil, errors: [ "No active session" ])
    end
  end
end
