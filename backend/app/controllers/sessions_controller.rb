# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSerializer

  after_action :ensure_cookie_attributes, only: [ :create ]

  def create
    # Ensure Authlogic has controller context
    UserSession.controller = self

    # Use the simple approach that worked before - let Authlogic handle it
    @user_session = UserSession.new(session_params.to_h)

    if @user_session.save
      render json: { user: user_payload(@user_session.user, include_admin: true) }, status: :created
    else
      render json: { errors: @user_session.errors.full_messages }, status: :unauthorized
    end
  end

  def destroy
    if current_user_session
      current_user_session.destroy
      head :no_content
    else
      head :unauthorized
    end
  end

  private

  def ensure_cookie_attributes
    return unless @user_session&.persisted?

    # Authlogic sets the cookie, but may not include same_site attribute
    # We need to ensure it has the correct attributes for cross-origin support
    user = @user_session.record
    return unless user&.respond_to?(:persistence_token)

    same_site = Rails.env.production? ? :none : :lax

    cookie_hash = {
      value: user.persistence_token,
      httponly: true,
      secure: Rails.env.production?,
      path: "/",
      same_site: same_site
    }

    if @user_session.remember_me?
      cookie_hash[:expires] = 2.weeks.from_now
    end

    # Set cookie with all required attributes
    response.set_cookie("_devhub_session", cookie_hash)

    Rails.logger.info "[Authlogic] Cookie set with same_site=#{same_site}, secure=#{cookie_hash[:secure]}"
  end

  def session_params
    permitted = params.require(:session).permit(:email, :password, :remember_me)
    permitted[:remember_me] = ActiveModel::Type::Boolean.new.cast(permitted[:remember_me])
    permitted
  end
end
