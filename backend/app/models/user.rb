class User < ApplicationRecord
  acts_as_authentic do |config|
    config.login_field = :email
    config.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end

  attr_accessor :password_confirmation

  has_many :assigned_tasks, class_name: "Task", as: :assignee, dependent: :nullify

  before_validation :normalize_email
  before_validation :sync_password_digest

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validate :password_matches_confirmation, if: :should_validate_password_confirmation?

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def should_validate_password_confirmation?
    password_confirmation.present? && password.present?
  end

  def password_matches_confirmation
    return if password_confirmation == password

    errors.add(:password_confirmation, "does not match password")
  end

  def sync_password_digest
    self.password_digest = crypted_password if crypted_password.present?
  end
end
