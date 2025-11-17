require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    project = build(:project)
    assert project.valid?
  end

  test "should require name" do
    project = build(:project, name: nil)
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    create(:project, name: "Test Project")
    duplicate_project = build(:project, name: "Test Project")
    assert_not duplicate_project.valid?
    assert_includes duplicate_project.errors[:name], "has already been taken"
  end

  test "should allow description" do
    project = build(:project, :with_description)
    assert project.valid?
    assert_equal "A detailed project description", project.description
  end

  test "should have many tasks" do
    project = create(:project)
    task1 = create(:task, project: project)
    task2 = create(:task, project: project)

    assert_equal 2, project.tasks.count
    assert_includes project.tasks, task1
    assert_includes project.tasks, task2
  end

  test "should destroy associated tasks when project is destroyed" do
    project = create(:project)
    task1 = create(:task, project: project)
    task2 = create(:task, project: project)

    project.destroy

    assert_raises(ActiveRecord::RecordNotFound) { task1.reload }
    assert_raises(ActiveRecord::RecordNotFound) { task2.reload }
  end

  test "should be case sensitive for name uniqueness" do
    create(:project, name: "Test Project")
    duplicate = build(:project, name: "test project")
    # Should be valid since uniqueness is case-sensitive by default
    assert duplicate.valid?
  end

  test "should have timestamps" do
    project = create(:project)
    assert_not_nil project.created_at
    assert_not_nil project.updated_at
  end

  test "should create project with tasks trait" do
    project = create(:project, :with_tasks)
    assert_equal 3, project.tasks.count
  end

  test "should create project with completed tasks trait" do
    project = create(:project, :with_completed_tasks)
    assert_equal 2, project.tasks.count
    assert project.tasks.all?(&:completed?)
  end
end
