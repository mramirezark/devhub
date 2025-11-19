# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, polymorphic: true, optional: true

  has_many :activities, as: :record, dependent: :destroy

  # Allowed assignee types for polymorphic association
  ALLOWED_ASSIGNEE_TYPES = %w[User].freeze

  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2
  }

  validates :title, presence: true
  validates :status, presence: true
  validate :assignee_type_supported

  # Query scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :assigned_to, ->(user) { where(assignee_type: "User", assignee_id: user.id) }

  after_update_commit :enqueue_status_tracking, if: :saved_change_to_status?

  private

  def enqueue_status_tracking
    change = saved_change_to_status
    before_status, after_status = change
    ActivityLoggerJob.perform_later(id, before_status, after_status)
  end

  def assignee_type_supported
    return if assignee_type.blank?

    unless ALLOWED_ASSIGNEE_TYPES.include?(assignee_type)
      errors.add(:assignee_type, "must be one of: #{ALLOWED_ASSIGNEE_TYPES.join(', ')}")
    end
  end
end
