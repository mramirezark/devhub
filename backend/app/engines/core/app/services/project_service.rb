# frozen_string_literal: true

module Core
  module Services
    class ProjectService
      extend Core::Services::Concerns::RecordLocator
      def self.list
        Project.includes(:tasks)
      end

      def self.find(id)
        locate_record(Project, id)
      end

      def self.create(name:, description: nil)
        project = Project.new(name: name, description: description)

        if project.save
          { success: true, project: project, errors: [] }
        else
          { success: false, project: nil, errors: project.errors.full_messages }
        end
      end

      def self.update(id:, name: nil, description: nil)
        project = locate_record(Project, id)
        return { success: false, errors: [ "Project not found" ] } unless project

        attributes = {
          name: name,
          description: description
        }.compact

        if attributes.empty?
          { success: true, project: project, errors: [] }
        elsif project.update(attributes)
          { success: true, project: project, errors: [] }
        else
          { success: false, project: nil, errors: project.errors.full_messages }
        end
      end

      def self.delete(id:)
        project = locate_record(Project, id)
        return { success: false, errors: [ "Project not found" ] } unless project

        project.destroy!
        { success: true, errors: [] }
      rescue StandardError => error
        { success: false, errors: [ error.message ] }
      end
    end
  end
end
