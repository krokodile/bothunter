class CreateGroupsPeople < ActiveRecord::Migration
  def up
    create_table :groups_people, id: false do |t|
      t.references :group
      t.references :person
    end
  end

  def down
    drop_table :groups_people
  end
end
