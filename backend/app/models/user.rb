# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_authentic do |config|
    config.login_field = :email
    config.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end

  attr_accessor :password_confirmation

  PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/

  has_many :assigned_tasks, class_name: "Task", as: :assignee, dependent: :nullify

  before_validation :normalize_email
  before_validation :sync_password_digest

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: :password_required?
  validate :password_matches_confirmation, if: :should_validate_password_confirmation?
  validate :password_complexity, if: :password_required?

  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def password_required?
    new_record? || password.present?
  end

  def should_validate_password_confirmation?
    password_confirmation.present? && password.present?
  end

  def password_matches_confirmation
    return if password_confirmation == password

    errors.add(:password_confirmation, "does not match password")
  end

  def password_complexity
    return if password.blank?

    unless password.match?(PASSWORD_REGEX)
      errors.add(:password, "must contain at least one uppercase letter, one lowercase letter, and one number")
    end
  end

  # Syncs Authlogic's crypted_password to password_digest for compatibility
  # This ensures password_digest is always in sync with crypted_password
  def sync_password_digest
    self.password_digest = crypted_password if crypted_password.present?
  end
end
