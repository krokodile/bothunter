class CreatePromocodes < ActiveRecord::Migration
  def up
    create_table :promocodes do |t|
      t.references :user
      t.integer :groups_limit
      t.integer :people_limit
      t.string :code, default: nil, uniq: true
    end

    add_index :promocodes, :code
  end

  def down
    drop_table :promocodes
  end
end
