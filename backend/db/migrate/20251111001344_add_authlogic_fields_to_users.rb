class AddAuthlogicFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :crypted_password, null: false, default: ""
      t.string :password_salt, null: false, default: ""
      t.string :persistence_token, null: false, default: ""
      t.string :single_access_token, null: false, default: ""
      t.string :perishable_token, null: false, default: ""

      t.integer :login_count, null: false, default: 0
      t.integer :failed_login_count, null: false, default: 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
    end

    add_index :users, :persistence_token, unique: true
    add_index :users, :single_access_token, unique: true
    add_index :users, :perishable_token, unique: true
  end
end
