# frozen_string_literal: true

module Types
  class AdminStatsType < Types::BaseObject
    description "Admin dashboard statistics"

    field :total_users, Integer, null: false
    field :total_projects, Integer, null: false
    field :total_tasks, Integer, null: false
    field :completed_tasks, Integer, null: false
    field :pending_tasks, Integer, null: false
    field :in_progress_tasks, Integer, null: false
  end
end
