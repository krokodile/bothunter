class AddCoverToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :cover, :string

  end
end
