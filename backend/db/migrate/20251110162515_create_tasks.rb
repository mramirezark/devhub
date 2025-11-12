class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.datetime :due_at
      t.references :assignee, polymorphic: true

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :due_at
    add_index :tasks, %i[assignee_type assignee_id]
  end
end
