class CreateGroupsUsers < ActiveRecord::Migration
  def up
    create_table :groups_users do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end

  def down
    drop_table :groups_users
  end
end
