# frozen_string_literal: true

module Admin
  module Services
    class UserService
      extend Admin::Services::Concerns::RecordLocator
      def self.list
        User.all.order(created_at: :desc)
      end

      def self.find(id)
        locate_record(User, id)
      end

      def self.create(name:, email:, password:, password_confirmation: nil, admin: false)
        user = User.new(
          name: name,
          email: email,
          password: password,
          password_confirmation: password_confirmation.presence || password,
          admin: admin
        )

        if user.save
          { success: true, user: user, errors: [] }
        else
          { success: false, user: nil, errors: user.errors.full_messages }
        end
      end

      def self.update(id:, name: nil, email: nil, admin: nil)
        user = locate_record(User, id)
        return { success: false, errors: [ "User not found" ] } unless user

        attributes = {
          name: name,
          email: email,
          admin: admin
        }.compact

        if attributes.empty?
          { success: true, user: user, errors: [] }
        elsif user.update(attributes)
          { success: true, user: user, errors: [] }
        else
          { success: false, user: nil, errors: user.errors.full_messages }
        end
      end

      def self.delete(id:, current_user_id:)
        user = locate_record(User, id)
        return { success: false, errors: [ "User not found" ] } unless user

        # Prevent deleting yourself
        if user.id == current_user_id
          return {
            success: false,
            errors: [ "You cannot delete your own account" ]
          }
        end

        if user.destroy
          { success: true, errors: [] }
        else
          { success: false, errors: user.errors.full_messages }
        end
      end

      def self.promote(id:)
        user = locate_record(User, id)
        return { success: false, errors: [ "User not found" ] } unless user

        if user.update(admin: true)
          { success: true, user: user, errors: [] }
        else
          { success: false, user: nil, errors: user.errors.full_messages }
        end
      end

      def self.demote(id:, current_user_id:)
        user = locate_record(User, id)
        return { success: false, errors: [ "User not found" ] } unless user

        # Prevent demoting yourself
        if user.id == current_user_id
          return {
            success: false,
            errors: [ "You cannot demote yourself" ]
          }
        end

        if user.update(admin: false)
          { success: true, user: user, errors: [] }
        else
          { success: false, user: nil, errors: user.errors.full_messages }
        end
      end
    end
  end
end
