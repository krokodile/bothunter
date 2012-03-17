class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.string :link
      t.string :name
      t.string :gid
      t.string :domain
      t.string :title
    end
  end

  def down
    drop_table :groups
  end
end
