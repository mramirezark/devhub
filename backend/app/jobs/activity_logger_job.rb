class ActivityLoggerJob < ApplicationJob
  queue_as :default

  def perform(task_id, previous_status, new_status)
    task = Task.find_by(id: task_id)
    return if task.nil?

    task.activities.create!(
      action: "Task status changed from #{label_for(previous_status)} to #{label_for(new_status)}"
    )
  end

  private

  def label_for(status_key)
    status_key.to_s.tr("_", " ").humanize
  end
end
