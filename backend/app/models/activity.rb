class Activity < ApplicationRecord
  belongs_to :record, polymorphic: true

  validates :record_type, presence: true
  validates :record_id, presence: true
  validates :action, presence: true
end
