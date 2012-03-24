class AddMembersCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :members_count, :bigint

  end
end
