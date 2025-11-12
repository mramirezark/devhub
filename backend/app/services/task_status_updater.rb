class TaskStatusUpdater
  Result = Struct.new(:task, :errors, keyword_init: true)

  attr_reader :task, :attributes

  def self.call(task:, attributes:)
    new(task:, attributes:).call
  end

  def initialize(task:, attributes:)
    @task = task
    @attributes = attributes.symbolize_keys
  end

  def call
    filtered_attributes = permitted_attributes.compact

    return Result.new(task:, errors: []) if filtered_attributes.empty?

    if task.update(filtered_attributes)
      Result.new(task:, errors: [])
    else
      Result.new(task: nil, errors: task.errors.full_messages)
    end
  end

  private

  def permitted_attributes
    attributes.slice(:title, :description, :status, :due_at, :assignee_id, :assignee_type)
  end
end
