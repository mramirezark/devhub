# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :record, polymorphic: true

  validates :record_type, presence: true
  validates :record_id, presence: true
  validates :action, presence: true

  # Query scopes
  scope :recent, -> { order(created_at: :desc) }
end
