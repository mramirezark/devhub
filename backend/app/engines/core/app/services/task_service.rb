# frozen_string_literal: true

module Core
  module Services
    class TaskService
      extend Core::Services::Concerns::RecordLocator
      def self.list(project_id: nil, status: nil)
        scope = Task.includes(:project, :activities)

        if project_id.present?
          normalized_project_id = extract_record_id(Project, project_id)
          scope = scope.where(project_id: normalized_project_id) if normalized_project_id
        end

        # Use explicit completed scope when filtering by completed status
        if status == "completed"
          scope = scope.completed
        elsif status.present?
          scope = scope.public_send(status)
        end

        scope.recent
      end

      def self.find(id)
        locate_record(Task, id)
      end

      def self.create(project_id:, title:, description: nil, status: nil, due_at: nil)
        project = locate_record(Project, project_id)
        return { success: false, errors: [ "Project not found" ] } if project.nil?

        task = project.tasks.new(
          title: title,
          description: description,
          status: status || "pending",
          due_at: due_at
        )

        if task.save
          { success: true, task: task, errors: [] }
        else
          { success: false, task: nil, errors: task.errors.full_messages }
        end
      end

      def self.update(id:, title: nil, description: nil, status: nil, due_at: nil)
        task = locate_record(Task, id)
        return { success: false, errors: [ "Task not found" ] } if task.nil?

        result = TaskStatusUpdater.call(
          task: task,
          attributes: {
            title: title,
            description: description,
            status: status,
            due_at: due_at
          }
        )

        {
          success: result.task.present?,
          task: result.task,
          errors: result.errors
        }
      end

      def self.delete(id:)
        task = locate_record(Task, id)
        return { success: false, errors: [ "Task not found" ] } unless task

        task.destroy!
        { success: true, errors: [] }
      rescue ActiveRecord::RecordNotDestroyed => error
        { success: false, errors: [ error.message ] }
      rescue ActiveRecord::RecordInvalid => error
        { success: false, errors: error.record.errors.full_messages }
      rescue StandardError => error
        Rails.logger.error "TaskService#delete failed: #{error.class}: #{error.message}"
        { success: false, errors: [ "An error occurred while deleting the task" ] }
      end

      def self.assign_to_user(task_id:, user_id:)
        task = locate_record(Task, task_id)
        user = locate_record(User, user_id)

        return { success: false, errors: [ "Task not found" ] } if task.nil?
        return { success: false, errors: [ "User not found" ] } if user.nil?

        if task.update(assignee: user)
          { success: true, task: task, errors: [] }
        else
          { success: false, task: nil, errors: task.errors.full_messages }
        end
      end
    end
  end
end
