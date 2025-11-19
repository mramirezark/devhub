# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
end
