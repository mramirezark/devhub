# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Core mutations (tasks, projects)
    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject
    field :create_task, mutation: Mutations::CreateTask
    field :update_task, mutation: Mutations::UpdateTask
    field :delete_task, mutation: Mutations::DeleteTask
    field :assign_task_to_user, mutation: Mutations::AssignTaskToUser

    # User CRUD mutations (admin only)
    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUser
    field :delete_user, mutation: Mutations::DeleteUser

    # Admin mutations (require admin privileges)
    field :promote_user, mutation: Mutations::PromoteUser
    field :demote_user, mutation: Mutations::DemoteUser
  end
end
