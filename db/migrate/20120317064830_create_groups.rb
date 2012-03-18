class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.string :domain
      t.string :title

      t.string :gid, null: false

      t.timestamps
    end

    add_index :groups, :gid
  end

  def down
    drop_table :groups
  end
end
