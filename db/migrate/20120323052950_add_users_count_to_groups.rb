class AddUsersCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :users_count, :bigint

  end
end
