class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.string :action, null: false
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :activities, %i[record_type record_id]
    add_index :activities, :created_at
  end
end
