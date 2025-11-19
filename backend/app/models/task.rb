# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, polymorphic: true, optional: true

  has_many :activities, as: :record, dependent: :destroy

  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2
  }

  validates :title, presence: true
  validates :status, presence: true
  validate :assignee_type_supported

  # Query scopes
  scope :completed, -> { where(status: :completed) }
  scope :recent, -> { order(created_at: :desc) }
  scope :assigned_to, ->(user) { where(assignee_type: "User", assignee_id: user.id) }

  after_commit :enqueue_status_tracking, on: %i[update]

  private

  def enqueue_status_tracking
    status_change = previous_changes["status"]
    return if status_change.blank?

    before_status, after_status = Array(status_change)
    return if before_status == after_status

    ActivityLoggerJob.perform_later(id, before_status, after_status)
  end

  def assignee_type_supported
    return if assignee_type.blank?

    errors.add(:assignee_type, "must be User") unless assignee_type == "User"
  end
end
