# frozen_string_literal: true

module Types
  class TaskStatusEnum < Types::BaseEnum
    Task.statuses.each_key do |status|
      value status.upcase, value: status, description: "Task status #{status}"
    end
  end
end
