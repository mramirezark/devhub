# frozen_string_literal: true

require "test_helper"

module Core
  module Services
    class ProjectServiceTest < ActiveSupport::TestCase
      test "list returns all projects" do
        project1 = create(:project)
        project2 = create(:project)

        projects = ProjectService.list

        assert_includes projects.map(&:id), project1.id
        assert_includes projects.map(&:id), project2.id
      end

      test "find returns project by id" do
        project = create(:project)

        found_project = ProjectService.find(project.id)

        assert_equal project, found_project
      end

      test "find returns nil for non-existent project" do
        found_project = ProjectService.find(99999)

        assert_nil found_project
      end

      test "create creates a new project" do
        result = ProjectService.create(
          name: "New Project",
          description: "Project description"
        )

        assert result[:success]
        assert_not_nil result[:project]
        assert_equal "New Project", result[:project].name
        assert_equal "Project description", result[:project].description
        assert_empty result[:errors]
      end

      test "create creates project without description" do
        result = ProjectService.create(name: "New Project")

        assert result[:success]
        assert_equal "New Project", result[:project].name
        assert_nil result[:project].description
      end

      test "create returns errors when project is invalid" do
        result = ProjectService.create(name: nil)

        assert_not result[:success]
        assert_nil result[:project]
        assert_not_empty result[:errors]
      end

      test "update updates project attributes" do
        project = create(:project, name: "Old Name")

        result = ProjectService.update(
          id: project.id,
          name: "New Name",
          description: "New Description"
        )

        assert result[:success]
        assert_equal "New Name", project.reload.name
        assert_equal "New Description", project.description
        assert_empty result[:errors]
      end

      test "update returns success with no changes when no attributes provided" do
        project = create(:project, name: "Original Name")

        result = ProjectService.update(id: project.id)

        assert result[:success]
        assert_equal "Original Name", project.reload.name
        assert_empty result[:errors]
      end

      test "update returns error when project not found" do
        result = ProjectService.update(id: 99999, name: "New Name")

        assert_not result[:success]
        assert_includes result[:errors], "Project not found"
      end

      test "update returns errors when project is invalid" do
        project = create(:project)

        # Pass empty string which will fail validation
        result = ProjectService.update(id: project.id, name: "")

        assert_not result[:success]
        assert_not_empty result[:errors]
      end

      test "delete destroys project" do
        project = create(:project)

        result = ProjectService.delete(id: project.id)

        assert result[:success]
        assert_empty result[:errors]
        assert_raises(ActiveRecord::RecordNotFound) { project.reload }
      end

      test "delete returns error when project not found" do
        result = ProjectService.delete(id: 99999)

        assert_not result[:success]
        assert_includes result[:errors], "Project not found"
      end

      test "delete destroys associated tasks" do
        project = create(:project)
        task = create(:task, project: project)

        result = ProjectService.delete(id: project.id)

        assert result[:success]
        assert_raises(ActiveRecord::RecordNotFound) { task.reload }
      end
    end
  end
end
